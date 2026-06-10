/// Data Tier — Repository
/// Path: lib/data/repositories/group_repository.dart
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/group_model.dart';

class GroupRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _db.collection('groups');

  // ─────────────────────────────────────────────
  // READ
  // ─────────────────────────────────────────────

  /// Returns all groups.
  /// Admins see everything; instructors see only groups they are assigned to.
  Future<List<GroupModel>> getGroups() async {
    final uid = _auth.currentUser?.uid;

    // Fetch the caller's role from Firestore to decide the query.
    String? role;
    if (uid != null) {
      final userDoc = await _db.collection('users').doc(uid).get();
      role = userDoc.data()?['role'] as String?;
    }

    QuerySnapshot<Map<String, dynamic>> snapshot;

    if (role == 'admin') {
      // Admins see ALL groups — filter in Dart so old docs without isArchived are included.
      snapshot = await _groups.get();
    } else {
      // Instructors see only their own groups.
      snapshot = await _groups
          .where('instructorIds', arrayContains: uid)
          .get();
    }

    // Filter out archived groups in Dart.
    // Firestore's where('isArchived', isEqualTo: false) excludes documents
    // that were created before the isArchived field was added (field doesn't exist).
    final list = snapshot.docs
        .map((doc) => GroupModel.fromMap(doc.data(), doc.id))
        .where((g) => !g.isArchived) // includes docs where field is missing (defaults to false)
        .toList();

    // Sort by creation date — newest last (ascending).
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  /// Returns a single group by its Firestore document ID, or null if not found.
  Future<GroupModel?> getGroupById(String id) async {
    final doc = await _groups.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return GroupModel.fromMap(doc.data()!, doc.id);
  }

  // ─────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────

  /// Creates a new group document.
  /// The caller is added to [instructorIds] only if they are an instructor.
  /// Admin-created groups start with an empty [instructorIds] list.
  /// No serial number is stored — display order is derived from [createdAt].
  Future<GroupModel> createGroup(String name) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    // Check role to decide whether to auto-assign caller as instructor.
    final callerDoc = await _db.collection('users').doc(uid).get();
    final callerRole = callerDoc.data()?['role'] as String?;
    final instructorIds = callerRole == 'instructor' ? [uid] : <String>[];

    final serialNumber = await _getNextGroupNumber();
    final now = Timestamp.now();
    final newDocRef = _groups.doc();

    final data = <String, dynamic>{
      'name': name,
      'instructorIds': instructorIds,
      'students': [],
      'createdAt': now,
      'serialNumber': serialNumber,
      'isArchived': false,
    };

    await newDocRef.set(data);

    return GroupModel(
      id: newDocRef.id,
      serialNumber: serialNumber,
      name: name,
      instructorIds: instructorIds,
      students: const [],
      createdAt: now.toDate(),
      isArchived: false,
    );
  }

  // ─────────────────────────────────────────────
  // UPDATE — group metadata
  // ─────────────────────────────────────────────

  /// Renames a group.
  Future<void> updateGroup(String id, String newName) async {
    await _groups.doc(id).update({'name': newName});
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────

  /// Soft-deletes a group by setting isArchived: true.
  /// Students inside the group are unassigned (their groupId field is cleared).
  /// To permanently delete, use permanentlyDeleteGroup() from the archive.
  Future<void> deleteGroup(String id) async {
    final group = await getGroupById(id);
    if (group == null) return;

    final batch = _db.batch();

    // Mark the group as archived
    batch.update(_groups.doc(id), {
      'isArchived': true,
      'archivedAt': FieldValue.serverTimestamp(),
    });

    // Unassign all students in the group (clear their groupId)
    for (final student in group.students) {
      batch.update(_db.collection('users').doc(student.id), {
        'groupId': FieldValue.delete(),
      });
    }

    await batch.commit();
  }

  /// Returns all archived groups (for the Admin Archive screen).
  Future<List<GroupModel>> getArchivedGroups() async {
    final snapshot = await _groups
        .where('isArchived', isEqualTo: true)
        .get();
    final list = snapshot.docs
        .map((doc) => GroupModel.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) {
      final aDate = a.archivedAt ?? a.createdAt;
      final bDate = b.archivedAt ?? b.createdAt;
      return bDate.compareTo(aDate); // newest archived first
    });
    return list;
  }

  /// Restores an archived group back to active.
  Future<void> restoreGroup(String id) async {
    await _groups.doc(id).update({
      'isArchived': false,
      'archivedAt': FieldValue.delete(),
    });
  }

  /// Permanently deletes a group from Firestore. Only callable from the archive.
  Future<void> permanentlyDeleteGroup(String id) async {
    await _groups.doc(id).delete();
  }

  // ─────────────────────────────────────────────
  // UPDATE — instructors
  // ─────────────────────────────────────────────

  /// Adds an instructor UID to the group's [instructorIds] array.
  Future<void> addInstructorToGroup(
      String groupId, String instructorId) async {
    await _groups.doc(groupId).update({
      'instructorIds': FieldValue.arrayUnion([instructorId]),
    });
  }

  /// Removes an instructor UID from the group's [instructorIds] array.
  Future<void> removeInstructorFromGroup(
      String groupId, String instructorId) async {
    await _groups.doc(groupId).update({
      'instructorIds': FieldValue.arrayRemove([instructorId]),
    });
  }

  // ─────────────────────────────────────────────
  // UPDATE — students (embedded array)
  // ─────────────────────────────────────────────

  /// Embeds a [GroupStudentEmbed] object into the group's [students] array.
  Future<void> addStudentToGroup(
    String groupId,
    String studentId,
    String levelId, {
    String name = '',
    String pin = '',
  }) async {
    final embed = <String, dynamic>{
      'id': studentId,
      'name': name,
      'level': levelId,
      'pin': pin,
      'lastActive': null,
    };

    final batch = _db.batch();

    batch.update(_groups.doc(groupId), {
      'students': FieldValue.arrayUnion([embed]),
    });

    // Use set+merge so it works even if groupId field doesn't exist yet on new student docs.
    batch.set(_db.collection('users').doc(studentId), {
      'groupId': groupId,
    }, SetOptions(merge: true));

    await batch.commit();
  }

  /// Removes a student embed from the group's [students] array.
  Future<void> removeStudentFromGroup(
      String groupId, String studentId) async {
    final group = await getGroupById(groupId);
    if (group == null) return;

    final embed = group.students
        .where((s) => s.id == studentId)
        .map((s) => s.toMap())
        .toList();

    if (embed.isEmpty) return;

    final batch = _db.batch();

    batch.update(_groups.doc(groupId), {
      'students': FieldValue.arrayRemove(embed),
    });

    batch.update(_db.collection('users').doc(studentId), {
      'groupId': FieldValue.delete(),
    });

    await batch.commit();
  }

  /// Updates the [lastActive] timestamp of a student embed inside a group.
  Future<void> updateStudentLastActive(
      String groupId, String studentId) async {
    final group = await getGroupById(groupId);
    if (group == null) return;

    final updatedStudents = group.students.map((s) {
      if (s.id != studentId) return s.toMap();
      return {
        ...s.toMap(),
        'lastActive': DateTime.now().toIso8601String(),
      };
    }).toList();

    await _groups.doc(groupId).update({'students': updatedStudents});
  }

  /// Updates the [pin] field of a student embed inside a group.
  Future<void> updateStudentPinInGroup(
      String groupId, String studentId, String newPin) async {
    final group = await getGroupById(groupId);
    if (group == null) return;

    final updatedStudents = group.students.map((s) {
      if (s.id != studentId) return s.toMap();
      return {...s.toMap(), 'pin': newPin};
    }).toList();

    await _groups.doc(groupId).update({'students': updatedStudents});
  }

  Future<int> _getNextGroupNumber() async {
    final docRef = _db.collection('counters').doc('groups');
    int next = 1;
    await _db.runTransaction((t) async {
      final snap = await t.get(docRef);
      final last = snap.exists ? (snap.data()?['lastNumber'] as int? ?? 0) : 0;
      next = last + 1;
      t.set(docRef, {'lastNumber': next}, SetOptions(merge: true));
    });
    return next;
  }
}
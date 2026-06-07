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
      // Admins see all groups (no orderBy to avoid missing index).
      snapshot = await _groups.get();
    } else {
      // Instructors see only their own groups (no orderBy to avoid composite index).
      snapshot = await _groups
          .where('instructorIds', arrayContains: uid)
          .get();
    }

    final list = snapshot.docs
        .map((doc) => GroupModel.fromMap(doc.data(), doc.id))
        .toList();

    // Sort in Dart to avoid requiring a Firestore composite index.
    list.sort((a, b) => a.serialNumber.compareTo(b.serialNumber));
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

  /// Creates a new group document and returns the resulting [GroupModel].
  Future<GroupModel> createGroup(String name) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');

    // Get current group count to generate a clean sequential number (1, 2, 3...)
    final countSnap = await _groups.count().get();
    final serialNumber = (countSnap.count ?? 0) + 1;

    final now = Timestamp.now();
    final newDocRef = _groups.doc();

    final data = <String, dynamic>{
      'serialNumber': serialNumber,
      'name': name,
      'instructorIds': [uid],
      'students': [],
      'createdAt': now,
    };

    await newDocRef.set(data);

    return GroupModel(
      id: newDocRef.id,
      serialNumber: serialNumber,
      name: name,
      instructorIds: [uid],
      students: const [],
      createdAt: now.toDate(),
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

  /// Deletes a group document permanently.
  Future<void> deleteGroup(String id) async {
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
}
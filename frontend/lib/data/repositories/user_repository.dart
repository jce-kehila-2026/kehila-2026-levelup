/// Data Tier — Repository
/// Path: lib/data/repositories/user_repository.dart
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  DocumentReference<Map<String, dynamic>> get _staffCounter =>
      _db.collection('counters').doc('staff');

  // ─────────────────────────────────────────────
  // READ
  // ─────────────────────────────────────────────

  Future<List<UserModel>> getInstructors() async {
    final snap = await _users
        .where('role', isEqualTo: 'instructor')
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  Future<List<UserModel>> getStudents() async {
    final snap = await _users
        .where('role', isEqualTo: 'student')
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  Future<UserModel?> getStudentById(String id) async {
    final doc = await _users.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<int> getStudentCountByLevel(String levelId) async {
    final snap = await _users
        .where('role', isEqualTo: 'student')
        .where('levelId', isEqualTo: levelId)
        .count()
        .get();
    return snap.count ?? 0;
  }

  // ─────────────────────────────────────────────
  // SEARCH
  // ─────────────────────────────────────────────

  Future<List<UserModel>> searchUsers(String query, {String? role}) async {
    final term = query.toLowerCase().trim();
    if (term.isEmpty) return [];
    var q = _users.where('searchKeywords', arrayContains: term);
    if (role != null) q = q.where('role', isEqualTo: role);
    final snap = await q.limit(20).get();
    return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  // ─────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────

  /// Creates an instructor directly in Firestore (no Cloud Function needed).
  /// To allow login, create the Firebase Auth account manually in Firebase Console
  /// using the same email address.
  Future<void> addInstructor(
    String name,
    String email,
    String? phoneNumber,
    String? address,
    List<String> assignedLevels, {
    String? username,
  }) async {
    final userNumber = DateTime.now().millisecondsSinceEpoch % 1000000 + 100;
    final searchKeywords = _buildKeywords(name, extra: ['instructor', email.toLowerCase()]);

    final docRef = _users.doc();
    await docRef.set({
      'name': name,
      'role': 'instructor',
      'email': email.trim().toLowerCase(),
      'phoneNumber': phoneNumber,
      'address': address,
      'assignedLevels': assignedLevels,
      'userNumber': userNumber,
      'searchKeywords': searchKeywords,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Creates a student directly in Firestore (no Firebase Auth needed).
  /// Students log in with username + PIN, not email/password.
  /// Returns the new Firestore document ID (used as the student's ID).
  Future<String> addStudent({
    required String name,
    required String username,
    required String pinCode,
    required String levelId,
    required int userNumber,
  }) async {
    final searchKeywords = _buildKeywords(name, extra: ['student', levelId, username]);

    // Create a new document with auto-generated ID
    final docRef = _users.doc();

    await docRef.set({
      'name': name,
      'role': 'student',
      'username': username.toLowerCase(),
      'pinCode': pinCode,
      'levelId': levelId,
      'userNumber': userNumber,
      'studentNumber': '#$userNumber',
      'searchKeywords': searchKeywords,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': null,
    });

    return docRef.id;
  }

  // ─────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────

  Future<void> updateInstructorProfile(
    String instructorId,
    String name,
    String email,
    String? phoneNumber,
    String? address,
  ) async {
    await _users.doc(instructorId).update({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'searchKeywords': _buildKeywords(name, extra: ['instructor']),
    });
  }

  Future<void> updateInstructorLevels(
      String instructorId, List<String> levels) async {
    await _users.doc(instructorId).update({'assignedLevels': levels});
  }

  Future<void> updateStudentLastActive(String studentId) async {
    await _users.doc(studentId).update({
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStudentProfile(String studentId,
      {String? pinCode, String? levelId}) async {
    final updates = <String, dynamic>{};
    if (pinCode != null) updates['pinCode'] = pinCode;
    if (levelId != null) updates['levelId'] = levelId;
    if (updates.isNotEmpty) await _users.doc(studentId).update(updates);
  }

  Future<void> unassignStudentsFromLevel(String levelId) async {
    final snap = await _users
        .where('role', isEqualTo: 'student')
        .where('levelId', isEqualTo: levelId)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'levelId': null});
    }
    await batch.commit();
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────

  Future<void> deleteInstructor(String instructorId) async {
    await _users.doc(instructorId).delete();
  }

  Future<void> deleteStudent(String studentId) async {
    await _users.doc(studentId).delete();
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  Future<int> _nextStaffNumber() async {
    int next = 2;
    await _db.runTransaction((t) async {
      final snap = await t.get(_staffCounter);
      final last = snap.exists ? (snap.data()?['lastNumber'] as int? ?? 1) : 1;
      next = last + 1;
      t.set(_staffCounter, {'lastNumber': next}, SetOptions(merge: true));
    });
    return next;
  }

  List<String> _buildKeywords(String name, {List<String> extra = const []}) {
    final keywords = <String>{};
    for (final part in name.toLowerCase().trim().split(RegExp(r'\s+'))) {
      for (int i = 1; i <= part.length; i++) {
        keywords.add(part.substring(0, i));
      }
    }
    keywords.addAll(extra);
    return keywords.toList();
  }
}
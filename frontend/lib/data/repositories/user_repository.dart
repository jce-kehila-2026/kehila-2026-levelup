/// Data Tier — Repository
/// Path: lib/data/repositories/user_repository.dart
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<List<UserModel>> getInstructors() async {
    final snap = await _users
        .where('role', isEqualTo: 'instructor')
        .where('isArchived', isEqualTo: false)
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  Future<List<UserModel>> getStudents() async {
    final snap = await _users
        .where('role', isEqualTo: 'student')
        .where('isArchived', isEqualTo: false)
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
        .where('isArchived', isEqualTo: false)
        .where('levelId', isEqualTo: levelId)
        .count()
        .get();
    return snap.count ?? 0;
  }

  Future<List<UserModel>> getArchivedUsers() async {
    final snap = await _users
        .where('isArchived', isEqualTo: true)
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  Future<List<UserModel>> searchUsers(String query, {String? role}) async {
    final term = query.toLowerCase().trim();
    if (term.isEmpty) return [];
    var q = _users
        .where('searchKeywords', arrayContains: term)
        .where('isArchived', isEqualTo: false);
    if (role != null) q = q.where('role', isEqualTo: role);
    final snap = await q.limit(20).get();
    return snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
  }

  Future<void> addInstructor(
    String name,
    String email,
    String? phoneNumber,
    String? address,
    List<String> assignedLevels, {
    String? username,
  }) async {
    final callable = _functions.httpsCallable('createUser');
    await callable.call({
      'role': 'instructor',
      'name': name,
      'email': email.trim().toLowerCase(),
      'phoneNumber': phoneNumber,
      'address': address,
      'assignedLevels': assignedLevels,
      'userNumber': DateTime.now().millisecondsSinceEpoch % 1000000 + 100,
    });
  }

  Future<String> addStudent({
    required String name,
    required String username,
    required String pinCode,
    required String levelId,
    required int userNumber,
  }) async {
    final callable = _functions.httpsCallable('createUser');
    final result = await callable.call({
      'role': 'student',
      'name': name,
      'username': username.toLowerCase().trim(),
      'pinCode': pinCode,
      'levelId': levelId,
      'userNumber': userNumber,
      'studentNumber': '#$userNumber',
    });
    return result.data['uid'] as String;
  }

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

  Future<void> updateStudentProfile(
    String studentId, {
    String? pinCode,
    String? levelId,
  }) async {
    final updates = <String, dynamic>{};
    if (pinCode != null) updates['pinCode'] = pinCode;
    if (levelId != null) updates['levelId'] = levelId;
    if (updates.isNotEmpty) await _users.doc(studentId).update(updates);
  }

  Future<void> unassignStudentsFromLevel(String levelId) async {
    final snap = await _users
        .where('role', isEqualTo: 'student')
        .where('isArchived', isEqualTo: false)
        .where('levelId', isEqualTo: levelId)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'levelId': null});
    }
    await batch.commit();
  }

  Future<void> deleteInstructor(String instructorId) async {
    final callable = _functions.httpsCallable('archiveUser');
    await callable.call({'uid': instructorId});
  }

  Future<void> deleteStudent(String studentId) async {
    final callable = _functions.httpsCallable('archiveUser');
    await callable.call({'uid': studentId});
  }

  Future<void> restoreUser(String uid) async {
    final callable = _functions.httpsCallable('restoreUser');
    await callable.call({'uid': uid});
  }

  Future<bool> emailExists(String email) async {
    final snap = await _users
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<bool> usernameExists(String username) async {
    final snap = await _users
        .where('username', isEqualTo: username.trim().toLowerCase())
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  List<String> _buildKeywords(String name,
      {List<String> extra = const []}) {
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

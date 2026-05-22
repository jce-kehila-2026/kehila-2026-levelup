/// Data Tier — Repository
/// Path: lib/data/repositories/auth_repository.dart
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _studentEmailDomain = '@students.levelup-26.local';

  String _studentEmailFor(String username) =>
      '${username.trim().toLowerCase()}$_studentEmailDomain';

  Future<String?> authenticateStaff(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final uid = cred.user?.uid;
      if (uid == null) return null;

      final role = await _roleForUid(uid);

      if (role == 'admin' || role == 'instructor') {
        return role;
      }
      await _auth.signOut();
      return null;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<String?> authenticateStudent(String username, String pin) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: _studentEmailFor(username),
        password: pin,
      );
      final uid = cred.user?.uid;
      if (uid == null) return null;

      final role = await _roleForUid(uid);

      if (role == 'student') {
        return 'student';
      }
      await _auth.signOut();
      return null;
    } on FirebaseAuthException {
      return null;
    }
  }
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      // Intentionally ignored.
    }
  }
  Future<void> signOut() => _auth.signOut();
  Future<String?> _roleForUid(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data();
    return data?['role'] as String?;
  }
}
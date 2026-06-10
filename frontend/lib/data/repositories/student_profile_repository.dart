/// Data Tier — Repository
/// Path: lib/data/repositories/student_profile_repository.dart
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student_profile_model.dart';
import '../../utils/level_helpers.dart';

class StudentProfileRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns the profile of the CURRENTLY LOGGED-IN student.
  /// Uses Firebase Auth to know who's signed in, then reads their user doc.
  Future<StudentProfile> getProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('No user is currently signed in.');
    }
    final profile = await getProfileById(uid);
    if (profile == null) {
      throw Exception('Profile not found for current user.');
    }
    return profile;
  }

  /// Reads a student's profile by their user document ID (== Auth UID).
  Future<StudentProfile?> getProfileById(String id) async {
    final doc = await _db.collection('users').doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;

    // Fields that live directly on the user document.
    return StudentProfile(
      id: doc.id,
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      studentId: data['studentNumber'] ?? '',
      level: levelDisplayName(data['levelId'] as String?),
      // TODO: BACKEND_INTEGRATION - FIREBASE
      // group, instructorName come from the groups collection (not built yet).
      // submissions/graded/correct come from the submissions collection.
      // Filled with safe defaults until those repos exist.
      group: '—',
      instructorName: '—',
      submissions: (data['submissions'] ?? 0).toInt(),
      graded: (data['graded'] ?? 0).toInt(),
      correct: (data['correct'] ?? 0).toInt(),
      studentNumber: data['studentNumber'],
      pinCode: data['pinCode'],
      lastActive: data['lastActive'] != null
          ? (data['lastActive'] is Timestamp
              ? (data['lastActive'] as Timestamp).toDate()
              : DateTime.tryParse(data['lastActive'].toString()))
          : null,
    );
  }
}
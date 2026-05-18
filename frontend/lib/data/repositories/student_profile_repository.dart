/// Data Tier — Repository
/// Path: lib/data/repositories/student_profile_repository.dart
library;

import '../models/student_profile_model.dart';

class StudentProfileRepository {
  Future<StudentProfile> getProfile() async {
    final profile = await getProfileById('1');
    return profile!;
  }

  Future<StudentProfile?> getProfileById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return StudentProfile(
      id: id,
      name: 'Alex Rivera',
      username: 'alex.rivera',
      studentId: '#1001',
      level: 'Level 1',
      group: 'Morning Group A',
      instructorName: 'Mr. Smith',
      submissions: 14,
      graded: 12,
      correct: 9,
      studentNumber: '#1001',
      pinCode: '9575',
      lastActive: DateTime.now().subtract(const Duration(minutes: 2)),
    );
  }
}

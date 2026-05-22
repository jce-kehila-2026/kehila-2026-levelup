/// Data Tier — Repository
/// Path: lib/data/repositories/student_profile_repository.dart
library;

import '../models/student_profile_model.dart';

class StudentProfileRepository {
  Future<StudentProfile> getProfile() async {
    final profile = await getProfileById('1');
    return profile!;
  }

  /// Returns the raw PIN for the default profile.
  Future<String> getPin() async {
    final profile = await getProfileById('1');
    return profile?.pinCode ?? '';
  }

  /// Returns a masked PIN (e.g. "**75") for display purposes.
  Future<String> getMaskedPin() async {
    final pin = await getPin();
    if (pin.length <= 2) return '*' * pin.length;
    final visible = pin.substring(pin.length - 2);
    return '${'*' * (pin.length - 2)}$visible';
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

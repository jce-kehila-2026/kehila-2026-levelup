/// Data Tier — Repository
/// Path: lib/data/repositories/auth_repository.dart
library;

class AuthRepository {
  /// Authenticates a staff member by email.
  /// Returns the role ('admin', 'instructor') or null if invalid.
  Future<String?> authenticateStaff(String email, String password) async {
    // Mock API delay
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'admin@levelup.edu') {
      return 'admin';
    } else if (email == 'ahmed@levelup.edu') {
      return 'instructor';
    }
    return null;
  }

  /// Sends a password reset email to the given address.
  Future<void> sendPasswordResetEmail(String email) async {
    // Mock API delay
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, this would call Firebase Auth: FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  /// Authenticates a student by username.
  /// Returns 'student' or null if invalid.
  Future<String?> authenticateStudent(String username, String pin) async {
    // Mock API delay
    await Future.delayed(const Duration(seconds: 1));

    if (username == 'alex.r' || username == 'maya.p' ) {
      return 'student';
    }
    return null;
  }
}

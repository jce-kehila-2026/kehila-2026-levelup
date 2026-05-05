/// Data Tier — Repository
/// Path: lib/data/repositories/user_repository.dart
library;

import '../models/user_model.dart';

class UserRepository {
  int _nextInstructorNumber = 4; // Next available (2 and 3 are taken by mock data)

  final List<UserModel> _instructors = [
    // Arabic instructor name — tests RTL rendering in instructor lists
    UserModel(
      id: '#2', userNumber: 2, name: 'د. أحمد الشريف',
      email: 'ahmed@levelup.edu', phoneNumber: '+1234567890',
      address: '123 Main St, City',
      role: UserRole.instructor,
      assignedLevels: ['l1', 'l2'],
      searchKeywords: ['ahmed', 'alsharif', 'instructor', 'level1', 'level2'],
    ),
    UserModel(
      id: '#3', userNumber: 3, name: 'Sarah Jenkins',
      email: 'sarah.j@levelup.edu', phoneNumber: '+0987654321',
      address: '456 Elm St, Town',
      role: UserRole.instructor,
      assignedLevels: ['l2', 'l3'],
      searchKeywords: ['sarah', 'jenkins', 'instructor', 'level2', 'level3'],
    ),
  ];

  final List<UserModel> _students = [
    UserModel(
      id: '#1001', userNumber: 1001, name: 'Alex Rivera',
      role: UserRole.student,
      levelId: 'l1',
      studentNumber: '#1001', username: 'alex.rivera', pinCode: '9575',
      lastActive: DateTime.now().subtract(const Duration(minutes: 2)),
      searchKeywords: ['alex', 'rivera', 'student', 'l1'],
    ),
    UserModel(
      id: '#1002', userNumber: 1002, name: 'Maya Patel',
      role: UserRole.student,
      levelId: 'l2',
      studentNumber: '#1002', username: 'maya.patel', pinCode: '3812',
      lastActive: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      searchKeywords: ['maya', 'patel', 'student', 'l2'],
    ),
    // Arabic student name — coexists with English names for mixed RTL/LTR rendering
    UserModel(
      id: '#1003', userNumber: 1003, name: 'عمر حسان',
      role: UserRole.student,
      levelId: 'l2',
      studentNumber: '#1003', username: 'omar.hassan', pinCode: '6204',
      lastActive: DateTime.now().subtract(const Duration(minutes: 45)),
      searchKeywords: ['omar', 'hassan', 'student', 'l2'],
    ),
    UserModel(
      id: '#1004', userNumber: 1004, name: 'Lina Chen',
      role: UserRole.student,
      levelId: 'l1',
      studentNumber: '#1004', username: 'lina.chen', pinCode: '7731',
      lastActive: DateTime.now().subtract(const Duration(days: 2)),
      searchKeywords: ['lina', 'chen', 'student', 'l1'],
    ),
    UserModel(
      id: '#1005', userNumber: 1005, name: 'James Walker',
      role: UserRole.student,
      levelId: 'l1',
      studentNumber: '#1005', username: 'james.walker', pinCode: '1489',
      lastActive: DateTime.now().subtract(const Duration(minutes: 1)),
      searchKeywords: ['james', 'walker', 'student', 'l1'],
    ),
    // Arabic student name — tests how cards handle RTL text alongside English peers
    UserModel(
      id: '#1006', userNumber: 1006, name: 'فاطمة الزهراء',
      role: UserRole.student,
      levelId: 'l1',
      studentNumber: '#1006', username: 'fatima.alzahra', pinCode: '5923',
      lastActive: null, // Never active
      searchKeywords: ['fatima', 'alzahra', 'student', 'l1'],
    ),
  ];

  Future<List<UserModel>> getInstructors() async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch all users where role == 'instructor'.
    // Expected Output: List of UserModel.
    await Future.delayed(const Duration(milliseconds: 500));
    return _instructors;
  }

  Future<List<UserModel>> getStudents() async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch all users where role == 'student'.
    // Expected Output: List of UserModel.
    await Future.delayed(const Duration(milliseconds: 500));
    return _students;
  }

  Future<UserModel?> getStudentById(String id) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch a specific student by document ID.
    // Expected Output: Single UserModel or null.
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _students.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addInstructor(String name, String email, String? phoneNumber, String? address, List<String> assignedLevels, {String? username}) async {
    // TODO(Phase 3): Firebase Auth — Generate random password and send password reset/welcome email
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Create a new User document in Firestore AND a new Firebase Auth user.
    // Expected Output: New document in 'users' collection where role == 'instructor'.
    await Future.delayed(const Duration(milliseconds: 500));
    final number = _nextInstructorNumber++;
    _instructors.add(UserModel(
      id: '#$number',
      userNumber: number, // Instructors: 2–1000
      name: name,
      email: email.isEmpty ? 'new@levelup.edu' : email,
      phoneNumber: phoneNumber,
      address: address,
      role: UserRole.instructor,
      assignedLevels: assignedLevels,
      username: username,
      searchKeywords: name.toLowerCase().split(' ')
        ..addAll(['instructor']),
    ));
  }

  Future<void> updateInstructorLevels(String instructorId, List<String> levels) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Update the 'assignedLevels' array for a specific instructor.
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _instructors.indexWhere((i) => i.id == instructorId);
    if (index != -1) {
      final old = _instructors[index];
      _instructors[index] = UserModel(
        id: old.id,
        userNumber: old.userNumber,
        name: old.name,
        email: old.email,
        phoneNumber: old.phoneNumber,
        address: old.address,
        role: old.role,
        assignedLevels: levels,
        searchKeywords: old.searchKeywords,
      );
    }
  }

  Future<void> updateInstructorProfile(String instructorId, String name, String email, String? phoneNumber, String? address) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Update 'name', 'email', 'phoneNumber', and 'address' fields for an instructor.
    // Note: If email changes, also update Firebase Auth email.
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _instructors.indexWhere((i) => i.id == instructorId);
    if (index != -1) {
      final old = _instructors[index];
      _instructors[index] = UserModel(
        id: old.id,
        userNumber: old.userNumber,
        name: name.isNotEmpty ? name : old.name,
        email: email.isNotEmpty ? email : old.email,
        phoneNumber: phoneNumber,
        address: address,
        role: old.role,
        assignedLevels: old.assignedLevels,
        searchKeywords: old.searchKeywords,
      );
    }
  }

  Future<void> deleteInstructor(String instructorId) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Delete the instructor document AND disable/delete their Firebase Auth account.
    await Future.delayed(const Duration(milliseconds: 300));
    _instructors.removeWhere((i) => i.id == instructorId);
  }

  Future<void> deleteStudent(String studentId) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Delete the student document.
    await Future.delayed(const Duration(milliseconds: 300));
    _students.removeWhere((s) => s.id == studentId);
  }
}

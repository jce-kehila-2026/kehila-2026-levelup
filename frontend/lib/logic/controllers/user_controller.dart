/// Logic Tier — Controller
/// Path: lib/logic/controllers/user_controller.dart
library;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/models/group_model.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/group_repository.dart';

class UserController extends ChangeNotifier {
  final UserRepository _repository;
  final GroupRepository _groupRepository;
  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'us-central1');

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<UserModel> _instructors = [];
  List<UserModel> _students = [];
  List<UserModel> _archivedUsers = [];
  List<GroupModel> _archivedGroups = [];

  UserController(this._repository, this._groupRepository) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _instructors = await _repository.getInstructors();
      _students = await _repository.getStudents();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── State ──────────────────────────────
  String _search = '';

  // ── Getters ────────────────────────────
  String get search => _search;

  List<UserModel> get instructors {
    if (_search.isEmpty) return _instructors;
    return _instructors.where((i) =>
      i.name.toLowerCase().contains(_search.toLowerCase()) ||
      (i.email ?? '').toLowerCase().contains(_search.toLowerCase())
    ).toList();
  }

  List<UserModel> get students {
    if (_search.isEmpty) return _students;
    final q = _search.toLowerCase();
    return _students.where((s) =>
      s.name.toLowerCase().contains(q) ||
      (s.username ?? '').toLowerCase().contains(q) ||
      (s.studentNumber ?? '').toLowerCase().contains(q)
    ).toList();
  }

  List<UserModel> get archivedUsers => _archivedUsers;
  List<GroupModel> get archivedGroups => _archivedGroups;

  // ── Actions ────────────────────────────

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  Future<void> addInstructor(String name, String email, String? phoneNumber, String? homeAddress, List<String> assignedLevels) async {
    if (name.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    try {
      final generatedUsername = _generateUsername(email);
      await _repository.addInstructor(name, email, phoneNumber, homeAddress, assignedLevels, username: generatedUsername);
      _instructors = await _repository.getInstructors();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generates a clean, lowercase, URL-safe username from an email address.
  /// Falls back to 'instructor_XXXX' with a random suffix if the email is empty.
  String _generateUsername(String email) {
    if (email.isNotEmpty && email.contains('@')) {
      // Take the prefix before the '@', sanitize it
      return email.split('@').first.toLowerCase().replaceAll(RegExp(r'[^a-z0-9._]'), '');
    }
    // Fallback: generate a random username
    final suffix = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
    return 'instructor_$suffix';
  }

  Future<void> updateInstructorLevels(String instructorId, List<String> levels) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.updateInstructorLevels(instructorId, levels);
      _instructors = await _repository.getInstructors();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateInstructorProfile(String instructorId, String name, String email, String? phoneNumber, String? homeAddress) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.updateInstructorProfile(instructorId, name, email, phoneNumber, homeAddress);
      _instructors = await _repository.getInstructors();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInstructor(String instructorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.deleteInstructor(instructorId);
      _instructors = await _repository.getInstructors();
      _archivedUsers = await _repository.getArchivedUsers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String studentId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.deleteStudent(studentId);
      _students = await _repository.getStudents();
      _archivedUsers = await _repository.getArchivedUsers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> emailExists(String email) => _repository.emailExists(email);

  Future<bool> usernameExists(String username) => _repository.usernameExists(username);

  Future<void> addStudent({
    required String name,
    required String username,
    required String pinCode,
    required String levelId,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userNumber = DateTime.now().millisecondsSinceEpoch % 900000 + 100000;
      await _repository.addStudent(
        name: name,
        username: username.toLowerCase().trim(),
        pinCode: pinCode,
        levelId: levelId,
        userNumber: userNumber,
      );
      _students = await _repository.getStudents();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetStudentPin(String studentId, String newPin) async {
    final callable = _functions.httpsCallable('resetStudentPin');
    await callable.call({'studentId': studentId, 'newPin': newPin});
  }

  Future<void> resendWelcomeEmail(String instructorId) async {
    final callable = _functions.httpsCallable('resendWelcomeEmail');
    await callable.call({'instructorId': instructorId});
  }

  Future<void> getArchivedUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _archivedUsers = await _repository.getArchivedUsers();
      _archivedGroups = await _groupRepository.getArchivedGroups();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreUser(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.restoreUser(uid);
      _archivedUsers = await _repository.getArchivedUsers();
      _archivedGroups = await _groupRepository.getArchivedGroups();
      _instructors = await _repository.getInstructors();
      _students = await _repository.getStudents();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> permanentlyDeleteUser(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.permanentlyDeleteUser(uid);
      _archivedUsers = await _repository.getArchivedUsers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreGroup(String groupId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _groupRepository.restoreGroup(groupId);
      _archivedGroups = await _groupRepository.getArchivedGroups();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> permanentlyDeleteGroup(String groupId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _groupRepository.permanentlyDeleteGroup(groupId);
      _archivedGroups = await _groupRepository.getArchivedGroups();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

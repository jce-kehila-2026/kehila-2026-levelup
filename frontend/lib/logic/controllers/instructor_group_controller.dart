/// Logic Tier — Controller
/// Path: lib/logic/controllers/instructor_group_controller.dart
library;

import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../data/models/group_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/group_repository.dart';
import '../../data/repositories/user_repository.dart';

class InstructorGroupController extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final UserRepository _userRepository;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<GroupModel> _groups = [];
  List<UserModel> _allStudents = [];

  InstructorGroupController(this._groupRepository, this._userRepository) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    try {
      _groups = await _groupRepository.getGroups();
      _allStudents = await _userRepository.getStudents();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── State ──────────────────────────────
  String _search = '';

  // ── Getters ────────────────────────────
  String get search => _search;

  List<GroupModel> get myGroups {
    if (_search.isEmpty) return _groups;
    final term = _search.toLowerCase();
    return _groups.where((g) => g.name.toLowerCase().contains(term)).toList();
  }

  List<UserModel> get allStudents => _allStudents;

  // ── Actions ────────────────────────────

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  /// Creates a new student and returns the created UserModel with credentials.
  Future<UserModel> createStudent(String fullName) async {
    final random = Random();
    final nextNumber = _allStudents.length + 1001;
    final studentNumber = '#$nextNumber';
    final username = _generateUsername(fullName);
    final pinCode = (1000 + random.nextInt(9000)).toString(); // 4-digit PIN

    final student = UserModel(
      id: studentNumber,
      userNumber: nextNumber,
      name: fullName,
      email: '${username.replaceAll('.', '')}@levelup.edu',
      role: UserRole.student,
      studentNumber: studentNumber,
      username: username,
      pinCode: pinCode,
      lastActive: null,
    );

    // In a real app, this would call a repository to persist.
    // For mock, we add to the in-memory list.
    _allStudents.add(student);
    notifyListeners();
    return student;
  }

  /// Generates a username from a full name (lowercase, first.last format).
  String _generateUsername(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0].toLowerCase()}.${parts[1].toLowerCase()}';
    }
    return parts[0].toLowerCase();
  }

  /// Resets the PIN for a student and returns the new PIN.
  String resetStudentPin(String studentId) {
    final random = Random();
    final newPin = (1000 + random.nextInt(9000)).toString();
    final index = _allStudents.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final old = _allStudents[index];
      _allStudents[index] = UserModel(
        id: old.id,
        userNumber: old.userNumber,
        name: old.name,
        email: old.email,
        role: old.role,
        studentNumber: old.studentNumber,
        username: old.username,
        pinCode: newPin,
        lastActive: old.lastActive,
        phoneNumber: old.phoneNumber,
        address: old.address,
        assignedLevels: old.assignedLevels,
      );
      notifyListeners();
    }
    return newPin;
  }

  Future<void> addGroup(String name) async {
    await _groupRepository.createGroup(name);
    _groups = await _groupRepository.getGroups();
    notifyListeners();
  }

  Future<void> deleteGroup(String id) async {
    await _groupRepository.deleteGroup(id);
    _groups = await _groupRepository.getGroups();
    notifyListeners();
  }

  Future<void> updateGroup(String id, String newName) async {
    await _groupRepository.updateGroup(id, newName);
    _groups = await _groupRepository.getGroups();
    notifyListeners();
  }

  Future<void> refresh() async {
    await _init();
  }
}

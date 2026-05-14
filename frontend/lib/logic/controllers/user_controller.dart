/// Logic Tier — Controller
/// Path: lib/logic/controllers/user_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class UserController extends ChangeNotifier {
  final UserRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<UserModel> _instructors = [];

  UserController(this._repository) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _instructors = await _repository.getInstructors();
    _isLoading = false;
    notifyListeners();
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

  // ── Actions ────────────────────────────

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  Future<void> addInstructor(String name, String email, String? phoneNumber, String? homeAddress, List<String> assignedLevels) async {
    if (name.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    // Auto-generate a URL-safe English username from the email prefix
    final generatedUsername = _generateUsername(email);

    await _repository.addInstructor(name, email, phoneNumber, homeAddress, assignedLevels, username: generatedUsername);
    _instructors = await _repository.getInstructors();
    _isLoading = false;
    notifyListeners();
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
    await _repository.updateInstructorLevels(instructorId, levels);
    _instructors = await _repository.getInstructors();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateInstructorProfile(String instructorId, String name, String email, String? phoneNumber, String? homeAddress) async {
    _isLoading = true;
    notifyListeners();
    await _repository.updateInstructorProfile(instructorId, name, email, phoneNumber, homeAddress);
    _instructors = await _repository.getInstructors();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteInstructor(String instructorId) async {
    _isLoading = true;
    notifyListeners();
    await _repository.deleteInstructor(instructorId);
    _instructors = await _repository.getInstructors();
    _isLoading = false;
    notifyListeners();
  }
}

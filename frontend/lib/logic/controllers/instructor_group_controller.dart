/// Logic Tier — Controller
/// Path: lib/logic/controllers/instructor_group_controller.dart
library;

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

  String? _error;
  String? get error => _error;

  Future<void> _init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _groups = await _groupRepository.getGroups();
      _allStudents = await _userRepository.getStudents();
    } catch (e) {
      _error = e.toString();
      debugPrint('InstructorGroupController._init error: $e');
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

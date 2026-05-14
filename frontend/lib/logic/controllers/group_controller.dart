/// Logic Tier — Controller
/// Path: lib/logic/controllers/group_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/group_model.dart';
import '../../data/repositories/group_repository.dart';

class GroupController extends ChangeNotifier {
  final GroupRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<GroupModel> _allGroups = [];

  GroupController(this._repository) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _allGroups = await _repository.getGroups();
    _isLoading = false;
    notifyListeners();
  }

  // ── State ──────────────────────────────
  String _search = '';

  // ── Getters ────────────────────────────
  String get search => _search;
  List<GroupModel> get groups {
    if (_search.isEmpty) return _allGroups;
    return _allGroups.where((g) => g.name.toLowerCase().contains(_search.toLowerCase())).toList();
  }

  // ── Actions ────────────────────────────

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  Future<void> deleteGroup(String id) async {
    _isLoading = true;
    notifyListeners();
    await _repository.deleteGroup(id);
    _allGroups = await _repository.getGroups();
    _isLoading = false;
    notifyListeners();
  }
}

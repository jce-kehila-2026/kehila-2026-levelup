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
  List<GroupModel> _archivedGroups = [];

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
  String _archiveSearch = '';

  // ── Getters ────────────────────────────
  String get search => _search;
  String get archiveSearch => _archiveSearch;

  List<GroupModel> get groups {
    if (_search.isEmpty) return _allGroups;
    return _allGroups.where((g) => g.name.toLowerCase().contains(_search.toLowerCase())).toList();
  }

  List<GroupModel> get archivedGroups {
    if (_archiveSearch.isEmpty) return _archivedGroups;
    return _archivedGroups.where((g) => g.name.toLowerCase().contains(_archiveSearch.toLowerCase())).toList();
  }

  // ── Actions ────────────────────────────

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setArchiveSearch(String value) {
    _archiveSearch = value;
    notifyListeners();
  }

  /// Reload active groups — called on screen mount to ensure fresh data.
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allGroups = await _repository.getGroups();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reload archived groups — called every time the Archive tab is opened.
  Future<void> loadArchivedGroups() async {
    _isLoading = true;
    notifyListeners();
    try {
      _archivedGroups = await _repository.getArchivedGroups();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createGroup(String name) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.createGroup(name);
      _allGroups = await _repository.getGroups();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Soft-deletes a group and immediately refreshes both the active and archived lists.
  Future<void> deleteGroup(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.deleteGroup(id);
      _allGroups = await _repository.getGroups();
      _archivedGroups = await _repository.getArchivedGroups();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreGroup(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.restoreGroup(id);
      _archivedGroups = await _repository.getArchivedGroups();
      _allGroups = await _repository.getGroups();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> permanentlyDeleteGroup(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.permanentlyDeleteGroup(id);
      _archivedGroups = await _repository.getArchivedGroups();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

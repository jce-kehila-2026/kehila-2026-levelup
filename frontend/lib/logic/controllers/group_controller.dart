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
    try {
      _allGroups = await _repository.getGroups();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    try {
      _allGroups = await _repository.getGroups();
      notifyListeners();
    } catch (e) {
      debugPrint('GroupController.refresh error: $e');
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

  /// Creates a group. Optimistic: adds to list immediately, then syncs from Firestore.
  Future<void> createGroup(String name) async {
    // Optimistic placeholder so the list grows instantly
    final placeholder = GroupModel(
      id: '__optimistic__${DateTime.now().millisecondsSinceEpoch}',
      serialNumber: (_allGroups.isEmpty ? 0 : _allGroups.last.serialNumber) + 1,
      name: name,
      instructorIds: [],
      students: [],
      createdAt: DateTime.now(),
      isArchived: false,
    );
    _allGroups = [..._allGroups, placeholder];
    notifyListeners();

    try {
      final created = await _repository.createGroup(name);
      // Replace placeholder with the real group from Firestore
      _allGroups = _allGroups
          .where((g) => g.id != placeholder.id)
          .toList()
        ..add(created);
      _allGroups.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      notifyListeners();
    } catch (e) {
      // Roll back on failure
      _allGroups = _allGroups.where((g) => g.id != placeholder.id).toList();
      notifyListeners();
      rethrow;
    }
  }

  /// Renames a group. Optimistic: updates name locally right away.
  Future<void> updateGroup(String id, String newName) async {
    final old = _allGroups.firstWhere((g) => g.id == id, orElse: () => throw Exception('Not found'));
    // Optimistic update
    _allGroups = _allGroups.map((g) => g.id == id ? _renamed(g, newName) : g).toList();
    notifyListeners();

    try {
      await _repository.updateGroup(id, newName);
    } catch (e) {
      // Roll back
      _allGroups = _allGroups.map((g) => g.id == id ? old : g).toList();
      notifyListeners();
      rethrow;
    }
  }

  /// Soft-deletes a group. Optimistic: removes from active list instantly.
  Future<void> deleteGroup(String id) async {
    final removed = _allGroups.firstWhere((g) => g.id == id, orElse: () => throw Exception('Not found'));
    // Optimistic remove
    _allGroups = _allGroups.where((g) => g.id != id).toList();
    notifyListeners();

    try {
      await _repository.deleteGroup(id);
      // Also prepend to archived list so the archive tab is up to date
      final archived = _archived(removed);
      _archivedGroups = [archived, ..._archivedGroups];
      notifyListeners();
    } catch (e) {
      // Roll back
      _allGroups = [..._allGroups, removed]
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      notifyListeners();
      rethrow;
    }
  }

  /// Restores an archived group. Optimistic: moves between lists instantly.
  Future<void> restoreGroup(String id) async {
    final removed = _archivedGroups.firstWhere((g) => g.id == id, orElse: () => throw Exception('Not found'));
    // Optimistic move
    _archivedGroups = _archivedGroups.where((g) => g.id != id).toList();
    final restored = _unarchived(removed);
    _allGroups = [..._allGroups, restored]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();

    try {
      await _repository.restoreGroup(id);
    } catch (e) {
      // Roll back
      _allGroups = _allGroups.where((g) => g.id != id).toList();
      _archivedGroups = [..._archivedGroups, removed];
      notifyListeners();
      rethrow;
    }
  }

  /// Permanently deletes an archived group. Optimistic: removes from archive instantly.
  Future<void> permanentlyDeleteGroup(String id) async {
    final removed = _archivedGroups.firstWhere((g) => g.id == id, orElse: () => throw Exception('Not found'));
    _archivedGroups = _archivedGroups.where((g) => g.id != id).toList();
    notifyListeners();

    try {
      await _repository.permanentlyDeleteGroup(id);
    } catch (e) {
      // Roll back
      _archivedGroups = [..._archivedGroups, removed];
      notifyListeners();
      rethrow;
    }
  }

  // ── Private helpers ────────────────────

  GroupModel _renamed(GroupModel g, String newName) => GroupModel(
        id: g.id,
        serialNumber: g.serialNumber,
        name: newName,
        instructorIds: g.instructorIds,
        students: g.students,
        sharedMaterialIds: g.sharedMaterialIds,
        createdAt: g.createdAt,
        isArchived: g.isArchived,
        archivedAt: g.archivedAt,
      );

  GroupModel _archived(GroupModel g) => GroupModel(
        id: g.id,
        serialNumber: g.serialNumber,
        name: g.name,
        instructorIds: g.instructorIds,
        students: g.students,
        sharedMaterialIds: g.sharedMaterialIds,
        createdAt: g.createdAt,
        isArchived: true,
        archivedAt: DateTime.now(),
      );

  GroupModel _unarchived(GroupModel g) => GroupModel(
        id: g.id,
        serialNumber: g.serialNumber,
        name: g.name,
        instructorIds: g.instructorIds,
        students: g.students,
        sharedMaterialIds: g.sharedMaterialIds,
        createdAt: g.createdAt,
        isArchived: false,
        archivedAt: null,
      );
}

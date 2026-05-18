/// Logic Tier — Controller
/// Path: lib/logic/controllers/curriculum_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/curriculum_model.dart';
import '../../data/repositories/curriculum_repository.dart';
import '../../data/repositories/assignment_repository.dart';

class CurriculumController extends ChangeNotifier {
  final CurriculumRepository _repository;
  final AssignmentRepository _assignmentRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CurriculumController(this._repository, this._assignmentRepository) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _levels = await _repository.getLevels();
    _isLoading = false;
    notifyListeners();
  }

  // ── State ──────────────────────────────
  List<LevelModel> _levels = [];
  String _search = '';
  final Set<String> _expandedLevels = {'l1'};
  final Set<String> _expandedWeeks = {'l1_w1'};

  // ── Getters ────────────────────────────
  String get search => _search;
  Set<String> get expandedLevels => _expandedLevels;
  Set<String> get expandedWeeks => _expandedWeeks;

  /// Returns levels filtered by the current search term.
  ///
  /// The filter is case-insensitive and matches against both the item title
  /// and any of its tags. Empty-level and empty-week containers are pruned
  /// so the UI never shows a level/week accordion with no children.
  ///
  /// When [_search] is empty the full unmodified list is returned directly,
  /// avoiding the allocation overhead of building filtered copies.
  List<LevelModel> get levels {
    if (_search.isEmpty) return _levels;
    final term = _search.toLowerCase();
    final filtered = <LevelModel>[];
    for (final level in _levels) {
      final filteredWeeks = <WeekModel>[];
      for (final week in level.weeks) {
        // Keep an item if its title or any tag contains the search term
        final filteredItems = week.items.where((item) =>
          item.title.toLowerCase().contains(term) ||
          item.searchTags.any((t) => t.toLowerCase().contains(term))
        ).toList();
        if (filteredItems.isNotEmpty) {
          filteredWeeks.add(WeekModel(id: week.id, name: week.name, items: filteredItems));
        }
      }
      if (filteredWeeks.isNotEmpty) {
        filtered.add(LevelModel(id: level.id, name: level.name, weeks: filteredWeeks));
      }
    }
    return filtered;
  }

  // When a search is active, force all accordion nodes open so matching items
  // are immediately visible without the user having to expand each level/week.
  bool isLevelExpanded(String id) => _search.isNotEmpty || _expandedLevels.contains(id);
  bool isWeekExpanded(String id) => _search.isNotEmpty || _expandedWeeks.contains(id);

  List<CurriculumSearchResult> get searchResults {
    if (_search.isEmpty) return [];
    final term = _search.toLowerCase();
    final List<CurriculumSearchResult> results = [];
    for (final level in _levels) {
      for (final week in level.weeks) {
        for (final item in week.items) {
          final matchTitle = item.title.toLowerCase().contains(term);
          final matchTag = item.searchTags.any((t) => t.toLowerCase().contains(term));
          if (matchTitle || matchTag) {
            results.add(CurriculumSearchResult(
              item: item,
              levelName: level.name,
              weekName: week.name,
            ));
          }
        }
      }
    }
    return results;
  }

  // ── Actions ────────────────────────────

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void toggleLevel(String id) {
    if (_expandedLevels.contains(id)) {
      _expandedLevels.remove(id);
    } else {
      _expandedLevels.add(id);
    }
    notifyListeners();
  }

  void toggleWeek(String id) {
    if (_expandedWeeks.contains(id)) {
      _expandedWeeks.remove(id);
    } else {
      _expandedWeeks.add(id);
    }
    notifyListeners();
  }

  Future<void> addLevel(String name) async {
    if (name.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    await _repository.addLevel(name);
    _levels = await _repository.getLevels();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWeek(int levelIndex, String name) async {
    if (name.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    await _repository.addWeek(levelIndex, name);
    _levels = await _repository.getLevels();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMaterial(int levelIndex, int weekIndex, String title, {String? content}) async {
    if (title.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    await _repository.addMaterial(levelIndex, weekIndex, title, content: content);
    _levels = await _repository.getLevels();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAssignment(int levelIndex, int weekIndex, String title, {String? content}) async {
    if (title.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    final id = 'ca_${DateTime.now().millisecondsSinceEpoch}';
    await _repository.addAssignment(levelIndex, weekIndex, title, content: content, id: id);
    await _assignmentRepository.addCentralAssignment(id, title, content: content);
    _levels = await _repository.getLevels();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleVisibility(int levelIndex, int weekIndex, int itemIndex) async {
    _isLoading = true;
    notifyListeners();
    await _repository.toggleVisibility(levelIndex, weekIndex, itemIndex);
    _levels = await _repository.getLevels();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateItem(int levelIndex, int weekIndex, int itemIndex, String title, String content) async {
    _isLoading = true;
    notifyListeners();
    await _repository.updateItem(levelIndex, weekIndex, itemIndex, title, content);
    _levels = await _repository.getLevels();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteItem(int levelIndex, int weekIndex, int itemIndex) async {
    _isLoading = true;
    notifyListeners();
    await _repository.deleteItem(levelIndex, weekIndex, itemIndex);
    _levels = await _repository.getLevels();
    _isLoading = false;
    notifyListeners();
  }
}

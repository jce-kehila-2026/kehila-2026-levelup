/// Logic Tier — Controller
/// Path: lib/logic/controllers/curriculum_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/curriculum_model.dart';
import '../../data/repositories/curriculum_repository.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../data/repositories/user_repository.dart';

class CurriculumController extends ChangeNotifier {
  final CurriculumRepository _repository;
  final AssignmentRepository _assignmentRepository;
  final UserRepository _userRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  CurriculumController(this._repository, this._assignmentRepository, this._userRepository) {
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
  final Set<String> _expandedLevels = {};
  final Set<String> _expandedWeeks = {};

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

  Future<int> getStudentCountForLevel(String levelId) =>
      _userRepository.getStudentCountByLevel(levelId);

  Future<void> editLevel(String levelId, String newName) async {
    if (newName.isEmpty) return;
    final oldName = _levels.firstWhere((l) => l.id == levelId).name;
    for (final level in _levels) {
      if (level.id == levelId) {
        level.name = newName;
        break;
      }
    }
    notifyListeners();

    try {
      await _repository.editLevel(levelId, newName);
      _levels = await _repository.getLevels();
      notifyListeners();
    } catch (e) {
      for (final level in _levels) {
        if (level.id == levelId) {
          level.name = oldName;
          break;
        }
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addLevel(String name) async {
    if (name.isEmpty) return;
    try {
      await _repository.addLevel(name);
      _levels = await _repository.getLevels();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteLevel(String levelId) async {
    final idx = _levels.indexWhere((l) => l.id == levelId);
    if (idx == -1) return;
    final removed = _levels.removeAt(idx);
    notifyListeners();

    try {
      await _repository.deleteLevel(levelId);
      _levels = await _repository.getLevels();
      notifyListeners();
    } catch (e) {
      _levels.insert(idx, removed);
      _levels.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addWeek(String levelId, String name) async {
    if (name.isEmpty) return;
    try {
      await _repository.addWeek(levelId, name);
      _levels = await _repository.getLevels();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addMaterial(String levelId, String weekId, String title, {String? content}) async {
    if (title.isEmpty) return;
    try {
      await _repository.addMaterial(levelId, weekId, title, content: content);
      _levels = await _repository.getLevels();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAssignment(String levelId, String weekId, String title, {String? content}) async {
    if (title.isEmpty) return;
    try {
      final id = 'ca_${DateTime.now().millisecondsSinceEpoch}';
      await _repository.addAssignment(levelId, weekId, title, content: content, id: id);
      await _assignmentRepository.addCentralAssignment(id, title, content: content);
      _levels = await _repository.getLevels();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleVisibility(String levelId, String weekId, String itemId) async {
    try {
      for (final level in _levels) {
        if (level.id == levelId) {
          for (final week in level.weeks) {
            if (week.id == weekId) {
              for (final item in week.items) {
                if (item.id == itemId) {
                  item.visible = !item.visible;
                  break;
                }
              }
            }
          }
        }
      }
      notifyListeners();
      await _repository.toggleVisibility(levelId, weekId, itemId);
      _levels = await _repository.getLevels();
      notifyListeners();
    } catch (e) {
      for (final level in _levels) {
        if (level.id == levelId) {
          for (final week in level.weeks) {
            if (week.id == weekId) {
              for (final item in week.items) {
                if (item.id == itemId) {
                  item.visible = !item.visible;
                  break;
                }
              }
            }
          }
        }
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateItem(String levelId, String weekId, String itemId, String title, String content) async {
    try {
      await _repository.updateItem(levelId, weekId, itemId, title, content);
      _levels = await _repository.getLevels();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteItem(String levelId, String weekId, String itemId) async {
    CurriculumItem? removedItem;
    for (final level in _levels) {
      if (level.id == levelId) {
        for (final week in level.weeks) {
          if (week.id == weekId) {
            final idx = week.items.indexWhere((i) => i.id == itemId);
            if (idx != -1) {
              removedItem = week.items.removeAt(idx);
              break;
            }
          }
        }
      }
    }
    notifyListeners();

    try {
      await _repository.deleteItem(levelId, weekId, itemId);
      if (itemId.startsWith('ca_')) {
        await _assignmentRepository.deleteAssignment(itemId);
      }
      _levels = await _repository.getLevels();
      notifyListeners();
    } catch (e) {
      if (removedItem != null) {
        for (final level in _levels) {
          if (level.id == levelId) {
            for (final week in level.weeks) {
              if (week.id == weekId) {
                week.items.add(removedItem);
                week.items.sort((a, b) => a.title.compareTo(b.title));
                break;
              }
            }
          }
        }
        notifyListeners();
      }
      rethrow;
    }
  }
}

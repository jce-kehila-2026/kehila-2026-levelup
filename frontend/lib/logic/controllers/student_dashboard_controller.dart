/// Logic Tier — Controller
/// Path: lib/logic/controllers/student_dashboard_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/curriculum_model.dart';

class StudentDashboardController extends ChangeNotifier {
  final bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ── State ──────────────────────────────
  String _search = '';

  /// Local cache — loaded once, searched synchronously.
  final List<CurriculumItem> _allLessons = [
    CurriculumItem(id: 'l1', type: CurriculumItemType.material, title: 'Introduction to Basics', searchTags: ['intro', 'basics'], visible: true),
    CurriculumItem(id: 'l2', type: CurriculumItemType.material, title: 'Variables and Data Types', searchTags: ['variables'], visible: true),
  ];

  // ── Getters ────────────────────────────
  String get search => _search;
  String get studentName => 'Alex Rivera';
  String get levelLabel => 'Level 1';
  String get groupLabel => 'Morning Group A';
  String get instructorName => 'Mr. Smith';
  int get lessonCount => 12;
  int get tasksDue => 2;
  int get newNotifications => 1;

  /// Filters the cached local list — no async, no repo call.
  List<CurriculumItem> get lessons {
    if (_search.isEmpty) return _allLessons;
    
    final term = _search.toLowerCase();
    return _allLessons.where((l) {
      final matchTitle = l.title.toLowerCase().contains(term);
      final matchTag = l.searchTags.any((t) => t.toLowerCase().contains(term));
      return matchTitle || matchTag;
    }).toList();
  }

  // ── Actions ────────────────────────────

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }
}

/// Logic Tier — Controller
/// Path: lib/logic/controllers/student_dashboard_controller.dart
library;

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/curriculum_model.dart';

class StudentDashboardController extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // ── State ──────────────────────────────
  String _search = '';
  String _studentName = '';
  String _levelLabel = '';

  StudentDashboardController() {
    _load();
  }

  /// Loads the currently logged-in student's basic info from their user doc.
  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          _studentName = data['name'] ?? '';
          _levelLabel = data['levelId'] ?? '';
        }
      }
    } catch (_) {
      // Leave fields blank on error; screen still renders.
    }
    _isLoading = false;
    notifyListeners();
  }

  // TODO: BACKEND_INTEGRATION - FIREBASE
  // The lesson library should come from CurriculumRepository (not built yet).
  // Stubbed empty until that repo exists.
  final List<CurriculumItem> _allLessons = [];

  // ── Getters ────────────────────────────
  String get search => _search;
  String get studentName => _studentName;
  String get levelLabel => _levelLabel;

  // TODO: BACKEND_INTEGRATION - FIREBASE
  // group/instructor come from the groups collection (not built yet).
  String get groupLabel => '—';
  String get instructorName => '—';

  // TODO: BACKEND_INTEGRATION - FIREBASE
  // These counts come from curriculum / assignments / notifications repos.
  int get lessonCount => _allLessons.length;
  int get tasksDue => 0;
  int get newNotifications => 0;

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
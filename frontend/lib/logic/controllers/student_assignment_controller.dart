/// Logic Tier — Controller
/// Path: lib/logic/controllers/student_assignment_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/assignment_model.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../di/service_locator.dart';

class StudentAssignmentController extends ChangeNotifier {
  final AssignmentRepository _repo = getIt<AssignmentRepository>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AssignmentModel> _allAssignments = [];

  // ── State ──────────────────────────────
  String _tab = 'pending'; // 'pending' or 'submitted'
  String _search = '';

  StudentAssignmentController() {
    loadAssignments();
  }

  // ── Getters ────────────────────────────
  String get tab => _tab;
  String get search => _search;

  List<AssignmentModel> get pendingAssignments {
    var list = _allAssignments.where((a) => a.isActive).toList();
    if (_search.isNotEmpty) {
      final term = _search.toLowerCase();
      list = list.where((a) => 
        a.title.toLowerCase().contains(term) || 
        (a.textContent?.toLowerCase().contains(term) ?? false)
      ).toList();
    }
    return list;
  }

  List<AssignmentModel> get submittedAssignments {
    var list = _allAssignments.where((a) => !a.isActive).toList();
    if (_search.isNotEmpty) {
      final term = _search.toLowerCase();
      list = list.where((a) => 
        a.title.toLowerCase().contains(term) || 
        (a.textContent?.toLowerCase().contains(term) ?? false)
      ).toList();
    }
    return list;
  }

  int get pendingCount => _allAssignments.where((a) => a.isActive).length;
  int get submittedCount => _allAssignments.where((a) => !a.isActive).length;

  // ── Actions ────────────────────────────

  Future<void> loadAssignments() async {
    _isLoading = true;
    notifyListeners();
    _allAssignments = await _repo.getStudentAssignments();
    _isLoading = false;
    notifyListeners();
  }

  void switchTab(String tab) {
    _tab = tab;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }
}

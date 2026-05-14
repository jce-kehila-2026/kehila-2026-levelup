/// Logic Tier — Controller
/// Path: lib/logic/controllers/instructor_dashboard_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/assignment_model.dart';
import '../../data/repositories/assignment_repository.dart';

class InstructorDashboardController extends ChangeNotifier {
  final AssignmentRepository _assignmentRepo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AssignmentModel> _activeAssignments = [];

  InstructorDashboardController(this._assignmentRepo) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _activeAssignments = await _assignmentRepo.getInstructorAssignments();
    _isLoading = false;
    notifyListeners();
  }

  // ── Getters ────────────────────────────
  int get pendingReview => 3;
  String get scopeLabel => 'Week 1';

  Map<String, String> get stats => {
        'myGroups': '2',
        'students': '36',
        'assignments': '5',
        'pendingReview': pendingReview.toString(),
      };

  List<AssignmentModel> get activeAssignments => _activeAssignments;
}

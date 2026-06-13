/// Logic Tier — Controller
/// Path: lib/logic/controllers/student_assignment_controller.dart
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/submission_model.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../data/repositories/submission_repository.dart';
import '../../di/service_locator.dart';

class StudentAssignmentController extends ChangeNotifier {
  final AssignmentRepository _repo = getIt<AssignmentRepository>();
  final SubmissionRepository _submissionRepo = getIt<SubmissionRepository>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AssignmentModel> _allAssignments = [];
  List<SubmissionModel> _studentSubmissions = [];

  // ── State ──────────────────────────────
  String _tab = 'pending'; // 'pending' or 'submitted'
  String _search = '';

  StreamSubscription<User?>? _authSub;

  StudentAssignmentController() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      loadAssignments();
    });
  }

  // ── Getters ────────────────────────────
  String get tab => _tab;
  String get search => _search;

  bool isSubmitted(String assignmentId) {
    return _studentSubmissions.any((s) => s.assignmentId == assignmentId);
  }

  List<AssignmentModel> get pendingAssignments {
    var list = _allAssignments.where((a) => !isSubmitted(a.id)).toList();
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
    var list = _allAssignments.where((a) => isSubmitted(a.id)).toList();
    if (_search.isNotEmpty) {
      final term = _search.toLowerCase();
      list = list.where((a) => 
        a.title.toLowerCase().contains(term) || 
        (a.textContent?.toLowerCase().contains(term) ?? false)
      ).toList();
    }
    return list;
  }

  int get pendingCount => _allAssignments.where((a) => !isSubmitted(a.id)).length;
  int get submittedCount => _allAssignments.where((a) => isSubmitted(a.id)).length;

  // ── Actions ────────────────────────────

  Future<void> loadAssignments() async {
    _isLoading = true;
    notifyListeners();
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final results = await Future.wait([
          _repo.getStudentAssignments(),
          _submissionRepo.getSubmissionsByStudent(uid),
        ]);
        _allAssignments = results[0] as List<AssignmentModel>;
        _studentSubmissions = results[1] as List<SubmissionModel>;
      } else {
        _allAssignments = [];
        _studentSubmissions = [];
      }
    } catch (e) {
      debugPrint('StudentAssignmentController.loadAssignments error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void switchTab(String tab) {
    _tab = tab;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

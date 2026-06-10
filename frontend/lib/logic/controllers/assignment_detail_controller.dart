/// Logic Tier — Controller
/// Path: lib/logic/controllers/assignment_detail_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/submission_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../data/repositories/submission_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../controllers/auth_controller.dart';

class AssignmentDetailController extends ChangeNotifier {
  final String assignmentId;
  final AssignmentRepository _repository;
  final AuthController _authController;
  final SubmissionRepository _submissionRepository;
  final UserRepository _userRepository;
  
  late AssignmentModel assignment;
  List<SubmissionModel> _submissions = [];
  List<UserModel> _students = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AssignmentDetailController(
    this.assignmentId,
    this._repository,
    this._authController,
    this._submissionRepository,
    this._userRepository,
  ) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    assignment = await _repository.getAssignmentById(assignmentId) ?? 
      AssignmentModel(id: assignmentId, title: 'Unknown Assignment', type: 'central', createdAt: DateTime.now(), deadline: DateTime.now());
    _submissions = await _submissionRepository.getSubmissionsByAssignment(assignmentId);
    _students = await _userRepository.getStudents();
    _isLoading = false;
    notifyListeners();
  }

  // ── State ──────────────────────────────
  String _answer = '';

  // ── Getters ────────────────────────────
  String get answer => _answer;
  List<SubmissionModel> get submissions => _submissions;

  /// Returns true only if the current user is a student.
  bool get isStudentRole {
    final role = _authController.authenticatedRole;
    return role == 'student';
  }

  bool get isAdminRole => _authController.authenticatedRole == 'admin';

  bool get isTemplateAssignment => assignment.type == 'central';

  /// Hide the submissions panel only for admins; instructors always see submissions.
  bool get hideSubmissionsPanel => isAdminRole;

  /// Looks up a student name by ID.
  String studentName(String studentId) {
    try {
      return _students.firstWhere((s) => s.id == studentId).name;
    } catch (_) {
      return studentId;
    }
  }

  // ── Actions ────────────────────────────
  void setAnswer(String value) {
    _answer = value;
    notifyListeners();
  }
  
  Future<void> submitAnswer() async {
    _isLoading = true;
    notifyListeners();
    debugPrint('Submitting answer for $assignmentId: $_answer');
    _isLoading = false;
    notifyListeners();
  }

  /// Grade a submission with status and optional feedback.
  Future<void> gradeSubmission(String submissionId, GradeStatus status, String? feedback) async {
    await _submissionRepository.gradeSubmission(submissionId, status, feedback);
    _submissions = await _submissionRepository.getSubmissionsByAssignment(assignmentId);
    notifyListeners();
  }
}

/// Logic Tier — Controller
/// Path: lib/logic/controllers/assignment_detail_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/assignment_model.dart';
import '../../data/models/submission_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/curriculum_model.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../data/repositories/submission_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/curriculum_repository.dart';
import '../controllers/auth_controller.dart';
import '../helpers/audit_log_helper.dart';

class AssignmentDetailController extends ChangeNotifier {
  final String assignmentId;
  final AssignmentRepository _repository;
  final AuthController _authController;
  final SubmissionRepository _submissionRepository;
  final UserRepository _userRepository;
  final CurriculumRepository _curriculumRepository;
  final AuditLogHelper _audit;
  
  late AssignmentModel assignment;
  List<SubmissionModel> _submissions = [];
  List<UserModel> _students = [];
  List<LevelModel> _levels = [];

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AssignmentDetailController(
    this.assignmentId,
    this._repository,
    this._authController,
    this._submissionRepository,
    this._userRepository,
    this._curriculumRepository,
    this._audit,
  ) {
    _audit.resolveIdentity();
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getAssignmentById(assignmentId),
        _submissionRepository.getSubmissionsByAssignment(assignmentId),
        _userRepository.getStudents(),
        _curriculumRepository.getLevels(),
      ]);
      assignment = (results[0] as AssignmentModel?) ?? 
        AssignmentModel(id: assignmentId, title: 'Unknown Assignment', type: 'central', createdAt: DateTime.now(), deadline: DateTime.now());
      _submissions = results[1] as List<SubmissionModel>;
      _students = results[2] as List<UserModel>;
      _levels = results[3] as List<LevelModel>;
    } catch (e) {
      debugPrint('AssignmentDetailController._init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── State ──────────────────────────────
  String _answer = '';

  // ── Getters ────────────────────────────
  String get answer => _answer;
  List<SubmissionModel> get submissions => _submissions;

  String get levelName {
    if (assignment.levelId == null) return '';
    try {
      return _levels.firstWhere((l) => l.id == assignment.levelId).name;
    } catch (_) {
      return '';
    }
  }

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
    // Find the student name for the log
    final sub = _submissions.where((s) => s.id == submissionId).firstOrNull;
    final studentN = sub != null ? studentName(sub.studentId) : null;
    final student = sub != null ? _students.where((s) => s.id == sub.studentId).firstOrNull : null;
    _audit.log(
      action: 'Graded submission',
      category: 'grading',
      targetPersonName: studentN,
      targetStudentNumber: student?.studentNumber,
      details: '"${assignment.title}" — ${status.name}',
    );
  }
}

/// Data Tier — Repository
/// Path: lib/data/repositories/submission_repository.dart
///
/// SECURITY: All submissions are text-based only — no file uploads.
/// Student answers are strictly plain text; instructor feedback is Delta JSON.
library;

import '../models/submission_model.dart';

class SubmissionRepository {
  final List<SubmissionModel> _submissions = [
    // ── Assignment a1: "Week 1: Fundamentals Quiz" ──────────
    SubmissionModel(
      id: 'sub1',
      assignmentId: 'a1',
      studentId: '#1001',
      submittedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      answer: '1. The Knight moves in an L-shape: two squares in one direction '
          'and one square perpendicular.\n'
          '2. No, the King cannot castle if it has already moved.\n'
          '3. En Passant is a special pawn capture that occurs when a pawn moves '
          'two squares from its starting position and lands beside an opponent\'s pawn.',
      feedback: 'Excellent answers! All three are correct. Great detail on En Passant.',
      status: GradeStatus.correct,
    ),
    SubmissionModel(
      id: 'sub2',
      assignmentId: 'a1',
      studentId: '#1005',
      submittedAt: DateTime.now().subtract(const Duration(hours: 8)),
      answer: '1. The Knight jumps over pieces in an L-shape.\n'
          '2. I think yes, the King can always castle.\n'
          '3. En Passant is when a pawn captures another pawn sideways.',
      feedback: 'Answer #2 is incorrect — the King cannot castle if it has '
          'already moved. Please review the castling rules and resubmit.',
      status: GradeStatus.incorrect,
    ),
    SubmissionModel(
      id: 'sub3',
      assignmentId: 'a1',
      studentId: '#1002',
      submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
      answer: '1. L-shape movement: 2+1 squares.\n'
          '2. No, the King must not have moved.\n'
          '3. En Passant allows a pawn to capture an adjacent pawn that just moved two squares.',
      status: GradeStatus.pending,
    ),

    // ── Assignment a2: "Board Setup Exercise" ───────────────
    SubmissionModel(
      id: 'sub4',
      assignmentId: 'a2',
      studentId: '#1001',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      answer: '',
      selectedChoice: 'Rook',
      feedback: 'Perfect notation and complete description.',
      status: GradeStatus.correct,
    ),
    SubmissionModel(
      id: 'sub5',
      assignmentId: 'a2',
      studentId: '#1002',
      submittedAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      answer: '',
      selectedChoice: 'Knight',
      feedback: 'Good description but please use algebraic notation as requested.',
      status: GradeStatus.incorrect,
    ),

    // ── Assignment a3: "Find the Fork" ──────────────────────
    // Arabic submission — student عمر حسان writes his answer in Arabic, testing RTL text in grading view
    SubmissionModel(
      id: 'sub6',
      assignmentId: 'a3',
      studentId: '#1003',
      submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
      answer: 'في الموضع المعطى، تقوم حركة الحصان Nf7+ بشوكة مزدوجة على الملك في e8 '
          'والرخ في h8. الحصان محمي بالفيل الموجود في c4، مما يجعل هذه الحركة رابحة.',
      status: GradeStatus.pending,
    ),

    // ── Assignment a4: "Opening Principles" ───────────
    SubmissionModel(
      id: 'sub7',
      assignmentId: 'a4',
      studentId: '#1001',
      submittedAt: DateTime.now().subtract(const Duration(hours: 12)),
      answer: '',
      selectedChoice: 'Control the center',
      status: GradeStatus.pending,
    ),
    SubmissionModel(
      id: 'sub8',
      assignmentId: 'a4',
      studentId: '#1003',
      submittedAt: DateTime.now().subtract(const Duration(hours: 6)),
      answer: '',
      selectedChoice: 'Checkmate the opponent',
      feedback: 'Good examples but the essay needs to be more detailed (200-300 words).',
      status: GradeStatus.incorrect,
    ),

    // ── Assignment a5: "Notation Practice" (past, all graded) ─
    SubmissionModel(
      id: 'sub9',
      assignmentId: 'a5',
      studentId: '#1002',
      submittedAt: DateTime.now().subtract(const Duration(days: 5)),
      answer: '1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7 6.Re1 b5 7.Bb3 d6 8.c3 O-O',
      feedback: 'Perfect notation — well done!',
      status: GradeStatus.correct,
    ),
    SubmissionModel(
      id: 'sub10',
      assignmentId: 'a5',
      studentId: '#1004',
      submittedAt: DateTime.now().subtract(const Duration(days: 4)),
      answer: '1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O',
      feedback: 'Correct so far but the recording is incomplete. Please finish all moves.',
      status: GradeStatus.incorrect,
    ),
    // Arabic submission — فاطمة الزهراء submits with Arabic annotation alongside algebraic notation
    SubmissionModel(
      id: 'sub11',
      assignmentId: 'a5',
      studentId: '#1006',
      submittedAt: DateTime.now().subtract(const Duration(days: 4, hours: 10)),
      answer: '1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7 6.Re1 b5 '
          '7.Bb3 d6 8.c3 O-O 9.h3 Nb8 10.d4\n\n'
          'ملاحظة: في الحركة الخامسة، يقوم الأبيض بالتهريج للحماية، وهي خطوة استراتيجية مهمة في دفاع روي لوبيز.',
      feedback: 'Excellent — complete and accurate.',
      status: GradeStatus.correct,
    ),
  ];

  /// Returns all submissions.
  Future<List<SubmissionModel>> getSubmissions() async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch all submissions (or filter by instructor's students).
    // Expected Output: List of SubmissionModel.
    await Future.delayed(const Duration(milliseconds: 500));
    return _submissions;
  }

  /// Returns submissions for a specific assignment.
  Future<List<SubmissionModel>> getSubmissionsByAssignment(String assignmentId) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch submissions where 'assignmentId' == assignmentId.
    // Expected Output: List of SubmissionModel.
    await Future.delayed(const Duration(milliseconds: 400));
    return _submissions.where((s) => s.assignmentId == assignmentId).toList();
  }

  /// Returns submissions by a specific student.
  Future<List<SubmissionModel>> getSubmissionsByStudent(String studentId) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch submissions where 'studentId' == studentId.
    // Expected Output: List of SubmissionModel.
    await Future.delayed(const Duration(milliseconds: 400));
    return _submissions.where((s) => s.studentId == studentId).toList();
  }

  /// Returns a single submission by ID.
  Future<SubmissionModel?> getSubmissionById(String id) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch a specific submission document by its ID.
    // Expected Output: Single SubmissionModel or null.
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _submissions.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns a submission for a specific assignment and student.
  Future<SubmissionModel?> getSubmissionForAssignment(String assignmentId, String studentId) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch a specific submission by assignmentId and studentId.
    // Expected Output: Single SubmissionModel or null.
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _submissions.firstWhere((s) => s.assignmentId == assignmentId && s.studentId == studentId);
    } catch (_) {
      return null;
    }
  }

  /// Adds a new text-based submission. [textContent] parameter name kept for
  /// API compatibility with callers; stored as [answer] per schema.
  Future<void> addSubmission({
    required String assignmentId,
    required String studentId,
    required String textContent,
    String? selectedChoice,
  }) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Create a new Submission document.
    // Expected Output: Add to the 'submissions' collection.
    // Note: 'textContent' should be mapped to the 'answer' field.
    await Future.delayed(const Duration(milliseconds: 500));
    _submissions.add(SubmissionModel(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      assignmentId: assignmentId,
      studentId: studentId,
      submittedAt: DateTime.now(),
      answer: textContent,
      selectedChoice: selectedChoice,
    ));
  }

  /// Updates an existing submission's answer.
  Future<void> updateSubmission({
    required String submissionId,
    required String textContent,
    String? selectedChoice,
  }) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Update 'answer' (textContent), 'selectedChoice', and 'submittedAt' fields of an existing submission.
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _submissions.indexWhere((s) => s.id == submissionId);
    if (index != -1) {
      final old = _submissions[index];
      _submissions[index] = SubmissionModel(
        id: old.id,
        assignmentId: old.assignmentId,
        studentId: old.studentId,
        submittedAt: DateTime.now(),
        answer: textContent,
        selectedChoice: selectedChoice,
        feedback: old.feedback,
        status: old.status,
      );
    }
  }

  /// Updates the grade status and feedback for a submission (instructor action).
  Future<void> gradeSubmission(String submissionId, GradeStatus status, String? feedback) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Update 'status' and 'feedback' fields of an existing submission.
    // Note: 'feedback' may contain Quill Delta JSON string.
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _submissions.indexWhere((s) => s.id == submissionId);
    if (index != -1) {
      _submissions[index].status = status;
      _submissions[index].feedback = feedback;
    }
  }
}

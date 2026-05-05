/// Data Tier — Repository
/// Path: lib/data/repositories/assignment_repository.dart
///
/// SECURITY: All assignments are text-based only — no file uploads.
library;

import '../models/assignment_model.dart';

class AssignmentRepository {
  final List<AssignmentModel> _instructorAssignments = [
    AssignmentModel(
      id: 'a1',
      title: 'Week 1: Fundamentals Quiz',
      type: 'central',
      isActive: true,
      groupName: 'Morning Group A',
      groupId: '1',
      instructorId: '#2',
      pendingCount: 3,
      gradedCount: 1,
      searchTags: ['week1', 'fundamentals', 'quiz', 'knight', 'castling', 'en passant'],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      deadline: DateTime.now().add(const Duration(days: 1, hours: 12)),
      textContent: 'Answer the following questions about chess fundamentals:\n'
          '1. How does the Knight move?\n'
          '2. Can the King castle if it has already moved?\n'
          '3. What is En Passant?',
    ),
    // Arabic title — coexists with English assignments for bilingual rendering tests
    AssignmentModel(
      id: 'a2',
      title: 'الأسبوع الأول: تمرين إعداد الرقعة',
      type: 'central',
      isActive: true,
      groupName: 'Morning Group A',
      groupId: '1',
      instructorId: '#2',
      pendingCount: 2,
      gradedCount: 2,
      searchTags: ['week1', 'board', 'setup', 'rook', 'corners'],
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      deadline: DateTime.now().add(const Duration(days: 3)),
      textContent: 'أي قطعة توضع في زوايا الرقعة؟ (Which piece is placed on the corners of the board?)',
      assignmentType: AssignmentType.multipleChoice,
      choices: ['Rook', 'Knight', 'Bishop', 'Queen'],
    ),
    AssignmentModel(
      id: 'a3',
      title: 'Week 2: Find the Fork',
      type: 'central',
      isActive: true,
      groupName: 'Evening Group B',
      groupId: '2',
      instructorId: '#3',
      pendingCount: 1,
      gradedCount: 0,
      searchTags: ['week2', 'tactics', 'fork', 'analysis'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      deadline: DateTime.now().add(const Duration(days: 5)),
      textContent: 'Analyze the following positions and identify the best fork '
          'opportunity for White. Explain your reasoning step by step.',
    ),
    // Arabic title — tests how assignment cards handle RTL titles in an LTR list
    AssignmentModel(
      id: 'a4',
      title: 'اختبار مبادئ الافتتاح',
      type: 'custom',
      isActive: true,
      groupName: 'Advanced Cohort',
      groupId: '4',
      instructorId: '#2',
      pendingCount: 2,
      gradedCount: 1,
      searchTags: ['opening', 'principles', 'center', 'control'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      deadline: DateTime.now().add(const Duration(days: 7)),
      textContent: 'ما هو الهدف الرئيسي في مرحلة الافتتاح؟ (What is a primary goal in the opening phase of a chess game?)',
      assignmentType: AssignmentType.multipleChoice,
      choices: ['Checkmate the opponent', 'Control the center', 'Exchange all pieces', 'Move the Queen early'],
    ),
    AssignmentModel(
      id: 'a5',
      title: 'Notation Practice',
      type: 'central',
      isActive: false,
      groupName: 'Weekend Workshop',
      groupId: '3',
      instructorId: '#3',
      pendingCount: 0,
      gradedCount: 3,
      searchTags: ['notation', 'algebraic', 'practice', 'moves'],
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      deadline: DateTime.now().subtract(const Duration(days: 3)),
      textContent: 'Record the moves of the provided game using standard algebraic notation.',
    ),
    // Central curriculum assignments — mirrored from CurriculumRepository so the
    // AssignmentDetailScreen can look them up by the same ID.
    AssignmentModel(
      id: 'ca_1',
      title: 'Piece Movement Quiz',
      type: 'central',
      isActive: true,
      pendingCount: 0,
      gradedCount: 0,
      searchTags: ['week1', 'fundamentals', 'movement'],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      deadline: DateTime.now().add(const Duration(days: 2)),
      textContent: 'Please complete the piece movement quiz.\n1. How does the Knight move?\n2. Can the King castle if it has already moved?\n3. What is En Passant?',
    ),
    AssignmentModel(
      id: 'ca_2',
      title: 'Find the Fork',
      type: 'central',
      isActive: true,
      pendingCount: 0,
      gradedCount: 0,
      searchTags: ['week2', 'tactics', 'fork'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      deadline: DateTime.now().add(const Duration(days: 5)),
      textContent: 'Analyze the provided positions and identify the best fork opportunity for White.',
    ),
    AssignmentModel(
      id: 'ca_3',
      title: 'واجب: تحديد التثبيتات',
      type: 'central',
      isActive: true,
      pendingCount: 0,
      gradedCount: 0,
      searchTags: ['tactics', 'pins', 'intermediate'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      deadline: DateTime.now().add(const Duration(days: 4)),
      textContent: 'في المواضع التالية، حدّد أي القطع محاصرة بتثبيت وكيف يمكن استغلال ذلك.',
    ),
    AssignmentModel(
      id: 'ca_4',
      title: 'Endgame Drill: King and Rook',
      type: 'central',
      isActive: false,
      pendingCount: 0,
      gradedCount: 0,
      searchTags: ['endgame', 'rook', 'advanced'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      deadline: DateTime.now().add(const Duration(days: 14)),
      textContent: 'Practice the Lucena and Philidor positions until you can execute them confidently from both sides.',
    ),
  ];

  Future<List<AssignmentModel>> getInstructorAssignments() async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch assignments created by or assigned to the current instructor.
    // Expected Output: List of AssignmentModel.
    // Note: Filter assignments where instructorId == currentUser.id.
    await Future.delayed(const Duration(milliseconds: 500));
    return _instructorAssignments;
  }

  Future<AssignmentModel?> getAssignmentById(String id) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch a specific assignment by its document ID.
    // Expected Output: Single AssignmentModel or null.
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _instructorAssignments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Registers a curriculum-pool assignment in this repository so that
  /// [AssignmentDetailScreen] can look it up by the same ID generated in
  /// [CurriculumRepository].
  Future<void> addCentralAssignment(String id, String title, {String? content}) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Copy a central curriculum assignment into the instructor's assignment pool.
    // Expected Output: Create new Assignment document where type == 'central'.
    await Future.delayed(const Duration(milliseconds: 100));
    _instructorAssignments.add(AssignmentModel(
      id: id,
      title: title,
      type: 'central',
      isActive: true,
      pendingCount: 0,
      gradedCount: 0,
      searchTags: [],
      createdAt: DateTime.now(),
      deadline: DateTime.now().add(const Duration(days: 7)),
      textContent: content,
    ));
  }

  Future<void> addInstructorAssignment(String title, {
    DateTime? deadline,
    String? textContent,
    AssignmentType assignmentType = AssignmentType.text,
    List<String>? choices,
    String? groupId,
    String? groupName,
  }) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Create a new custom assignment document.
    // Expected Output: Create new Assignment document where type == 'custom'.
    await Future.delayed(const Duration(milliseconds: 500));
    _instructorAssignments.add(AssignmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      type: 'custom',
      isActive: true,
      groupName: groupName ?? 'Morning Group A',
      groupId: groupId ?? '1',
      instructorId: '#2',
      pendingCount: 0,
      searchTags: [],
      createdAt: DateTime.now(),
      deadline: deadline ?? DateTime.now().add(const Duration(days: 7)),
      textContent: textContent,
      assignmentType: assignmentType,
      choices: choices,
    ));
  }

  Future<void> deleteAssignment(String id) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Delete the assignment document.
    // Note: Should we also delete related submissions? Consider Firebase Functions for cascading deletes.
    await Future.delayed(const Duration(milliseconds: 300));
    _instructorAssignments.removeWhere((a) => a.id == id);
  }

  Future<void> updateAssignmentDeadline(String id, DateTime newDeadline) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Update only the deadline field of a specific assignment document.
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _instructorAssignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _instructorAssignments[index];
      _instructorAssignments[index] = AssignmentModel(
        id: old.id,
        title: old.title,
        type: old.type,
        isActive: old.isActive,
        groupName: old.groupName,
        groupId: old.groupId,
        instructorId: old.instructorId,
        pendingCount: old.pendingCount,
        gradedCount: old.gradedCount,
        searchTags: old.searchTags,
        createdAt: old.createdAt,
        deadline: newDeadline,
        textContent: old.textContent,
        assignmentType: old.assignmentType,
        choices: old.choices,
      );
    }
  }

  Future<void> updateAssignmentContent(String id, String title, String textContent,
      AssignmentType assignmentType, List<String> choices,
      {String? groupId, String? groupName}) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Update assignment content, title, and choices fields.
    // Expected Output: Update existing Assignment document.
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _instructorAssignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _instructorAssignments[index];
      _instructorAssignments[index] = AssignmentModel(
        id: old.id,
        title: title,
        type: old.type,
        isActive: old.isActive,
        groupName: groupName ?? old.groupName,
        groupId: groupId ?? old.groupId,
        instructorId: old.instructorId,
        pendingCount: old.pendingCount,
        gradedCount: old.gradedCount,
        searchTags: old.searchTags,
        createdAt: old.createdAt,
        deadline: old.deadline,
        textContent: textContent,
        assignmentType: assignmentType,
        choices: choices,
      );
    }
  }
}

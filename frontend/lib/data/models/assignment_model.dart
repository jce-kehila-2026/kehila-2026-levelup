/// Data Tier — Model
/// Path: lib/data/models/assignment_model.dart
///
/// SECURITY REQUIREMENT: All assignments are text-based only.
/// No file-upload parameters are permitted in this model.
library;

enum AssignmentType { text, multipleChoice }

class AssignmentModel {
  final String id;
  String title;
  String type; // 'central' or 'custom'
  bool isActive;
  String? groupName; // Display name (kept for UI convenience)
  String? groupId; // Firestore group document reference
  String? instructorId; // Firestore instructor uid reference
  int pendingCount;
  int gradedCount;

  /// Search tags for segmented-array Firestore queries.
  final List<String> searchTags;

  /// The date the assignment was created.
  final DateTime createdAt;

  /// The deadline for submission.
  final DateTime deadline;

  /// Text-based assignment content (the assignment prompt/body).
  final String? textContent;

  /// The type of assignment (text or multipleChoice).
  final AssignmentType assignmentType;

  /// The choices for a multiple choice assignment.
  final List<String>? choices;

  AssignmentModel({
    required this.id,
    required this.title,
    this.type = 'central',
    this.isActive = true,
    this.groupName,
    this.groupId,
    this.instructorId,
    this.pendingCount = 0,
    this.gradedCount = 0,
    this.searchTags = const [],
    required this.createdAt,
    required this.deadline,
    this.textContent,
    this.assignmentType = AssignmentType.text,
    this.choices,
  });

  /// Returns true if the deadline has passed.
  bool get isOverdue => DateTime.now().isAfter(deadline);

  /// Human-readable deadline label relative to now.
  String get deadlineText {
    final now = DateTime.now();
    final diff = deadline.difference(now);
    if (diff.isNegative) {
      final days = diff.inDays.abs();
      if (days == 0) return 'Overdue (today)';
      return 'Overdue by ${days}d';
    }
    if (diff.inDays == 0) {
      return 'Due today, ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Tomorrow, ${deadline.hour.toString().padLeft(2, '0')}:${deadline.minute.toString().padLeft(2, '0')}';
    if (diff.inDays < 7) return 'In ${diff.inDays} days';
    return 'In ${(diff.inDays / 7).ceil()} weeks';
  }

  factory AssignmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AssignmentModel(
      id: documentId,
      title: map['title'] ?? '',
      type: map['type'] ?? 'central',
      isActive: map['isActive'] ?? true,
      groupName: map['groupName'],
      groupId: map['groupId'],
      instructorId: map['instructorId'],
      pendingCount: map['pendingCount']?.toInt() ?? 0,
      gradedCount: map['gradedCount']?.toInt() ?? 0,
      searchTags: List<String>.from(map['searchTags'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'].toString())
          : DateTime.now(),
      textContent: map['textContent'],
      assignmentType: map['assignmentType'] == 'multipleChoice'
          ? AssignmentType.multipleChoice
          : AssignmentType.text,
      choices: map['choices'] != null ? List<String>.from(map['choices']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type,
      'isActive': isActive,
      'groupName': groupName,
      'groupId': groupId,
      'instructorId': instructorId,
      'pendingCount': pendingCount,
      'gradedCount': gradedCount,
      'searchTags': searchTags,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'textContent': textContent,
      'assignmentType': assignmentType.name,
      'choices': choices,
    };
  }
}

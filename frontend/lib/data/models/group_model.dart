/// Data Tier — Model
/// Path: lib/data/models/group_model.dart
library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Embedded student object stored inside a GroupModel document.
class GroupStudentEmbed {
  final String id;
  final String name;
  final String level; // levelId, e.g. 'l1'
  final String pin;
  final DateTime? lastActive;

  const GroupStudentEmbed({
    required this.id,
    required this.name,
    required this.level,
    required this.pin,
    this.lastActive,
  });

  factory GroupStudentEmbed.fromMap(Map<String, dynamic> map) {
    return GroupStudentEmbed(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      level: map['level'] ?? '',
      pin: map['pin'] ?? '',
      lastActive: _parseDate(map['lastActive']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'pin': pin,
      'lastActive': lastActive?.toIso8601String(),
    };
  }
}

/// Safely parses a date value that may be a Firestore Timestamp, a String, or null.
DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is String && value.isNotEmpty) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
  return null;
}

class GroupModel {
  final String id;
  final int serialNumber;
  final String name;
  final List<String> instructorIds;
  final DateTime createdAt;

  /// Embedded student objects for optimised local reads.
  final List<GroupStudentEmbed> students;

  GroupModel({
    required this.id,
    required this.serialNumber,
    required this.name,
    required this.createdAt,
    this.instructorIds = const [],
    this.students = const [],
  });

  /// Derived map of studentId → levelId for backward-compatible lookups.
  Map<String, String> get studentLevels =>
      Map.fromEntries(students.map((s) => MapEntry(s.id, s.level)));

  /// All student IDs in this group.
  List<String> get studentIds => students.map((s) => s.id).toList();

  /// The distinct levels present in this group.
  Set<String> get activeLevels => students.map((s) => s.level).toSet();

  factory GroupModel.fromMap(Map<String, dynamic> map, String documentId) {
    return GroupModel(
      id: documentId,
      serialNumber: (map['serialNumber'] as num?)?.toInt() ?? 0,
      name: map['name'] ?? '',
      instructorIds: List<String>.from(map['instructorIds'] ?? []),
      students: (map['students'] as List<dynamic>?)
              ?.map((s) => GroupStudentEmbed.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
      // ✅ Handles Firestore Timestamp, ISO String, or null
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serialNumber': serialNumber,
      'name': name,
      'instructorIds': instructorIds,
      'students': students.map((s) => s.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

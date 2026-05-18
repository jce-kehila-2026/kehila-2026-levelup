/// Data Tier — Model
/// Path: lib/data/models/audit_log_model.dart
library;

class AuditLog {
  final String id;
  final String action;
  final String? details;

  /// Display name of the actor (UI convenience field).
  final String performerName;

  /// Role of the actor (UI convenience field).
  final String performerRole; // 'admin', 'instructor', 'student'

  /// UID or document reference of the actor (schema canonical field).
  final String performedBy;

  /// Schema canonical timestamp used for Firestore ordering and queries.
  final DateTime time;

  /// High-precision timestamp kept for display purposes.
  final DateTime preciseTimestamp;

  final String serialNumber;

  /// The name of the person the action was performed on (if applicable).
  final String? targetPersonName;

  /// The student number of the target (e.g., "#1005"), if applicable.
  final String? targetStudentNumber;

  AuditLog({
    required this.id,
    required this.action,
    this.details,
    required this.performerName,
    required this.performerRole,
    required this.performedBy,
    required this.time,
    required this.preciseTimestamp,
    required this.serialNumber,
    this.targetPersonName,
    this.targetStudentNumber,
  });

  factory AuditLog.fromMap(Map<String, dynamic> map, String documentId) {
    final timestamp = map['time'] != null
        ? DateTime.parse(map['time'].toString())
        : (map['preciseTimestamp'] != null
            ? DateTime.parse(map['preciseTimestamp'].toString())
            : DateTime.now());

    return AuditLog(
      id: documentId,
      action: map['action'] ?? '',
      details: map['details'],
      performerName: map['performerName'] ?? '',
      performerRole: map['performerRole'] ?? '',
      performedBy: map['performedBy'] ?? '',
      time: timestamp,
      preciseTimestamp: timestamp,
      serialNumber: map['serialNumber'] ?? '',
      targetPersonName: map['targetPersonName'],
      targetStudentNumber: map['targetStudentNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'details': details,
      'performerName': performerName,
      'performerRole': performerRole,
      'performedBy': performedBy,
      'time': time.toIso8601String(),
      'preciseTimestamp': preciseTimestamp.toIso8601String(),
      'serialNumber': serialNumber,
      'targetPersonName': targetPersonName,
      'targetStudentNumber': targetStudentNumber,
    };
  }
}

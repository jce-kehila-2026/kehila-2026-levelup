/// Data Tier — Model
/// Path: lib/data/models/user_model.dart
library;

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, instructor, student }

class UserModel {
  final String id;
  final int userNumber;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final UserRole role;
  final List<String> assignedLevels;
  final List<String> searchKeywords;
  final String? levelId;
  final String? studentNumber;
  final String? username;
  final String? pinCode;
  final DateTime? lastActive;
  final bool isArchived;
  final DateTime? createdAt;
  final String? groupId;

  UserModel({
    required this.id,
    required this.userNumber,
    required this.name,
    this.email,
    this.phoneNumber,
    this.address,
    required this.role,
    this.assignedLevels = const [],
    this.searchKeywords = const [],
    this.levelId,
    this.studentNumber,
    this.username,
    this.pinCode,
    this.lastActive,
    this.isArchived = false,
    this.createdAt,
    this.groupId,
  });

  bool get isOnline {
    if (lastActive == null) return false;
    return DateTime.now().difference(lastActive!).inMinutes < 5;
  }

  String get lastActiveLabel {
    if (lastActive == null) return 'Never';
    final diff = DateTime.now().difference(lastActive!);
    if (diff.inMinutes < 5) return 'Online';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    UserRole parsedRole = UserRole.student;
    if (map['role'] == 'admin') parsedRole = UserRole.admin;
    if (map['role'] == 'instructor') parsedRole = UserRole.instructor;

    return UserModel(
      id: documentId,
      userNumber: (map['userNumber'] as num?)?.toInt() ?? 0,
      name: map['name'] ?? '',
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      role: parsedRole,
      assignedLevels: List<String>.from(map['assignedLevels'] ?? []),
      searchKeywords: List<String>.from(map['searchKeywords'] ?? []),
      levelId: map['levelId'],
      studentNumber: map['studentNumber'],
      username: map['username'],
      pinCode: map['pinCode'],
      lastActive: _parseTimestamp(map['lastActive']),
      isArchived: map['isArchived'] as bool? ?? false,
      createdAt: _parseTimestamp(map['createdAt']),
      groupId: map['groupId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userNumber': userNumber,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'role': role.name,
      'assignedLevels': assignedLevels,
      'searchKeywords': searchKeywords,
      'levelId': levelId,
      'studentNumber': studentNumber,
      'username': username,
      'pinCode': pinCode,
      'lastActive': lastActive?.toIso8601String(),
      'isArchived': isArchived,
      'createdAt': createdAt?.toIso8601String(),
      'groupId': groupId,
    };
  }
}

DateTime? _parseTimestamp(dynamic value) {
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

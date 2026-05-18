/// Data Tier — Model
/// Path: lib/data/models/user_model.dart
library;

enum UserRole { admin, instructor, student }

class UserModel {
  final String id;
  final int userNumber;
  final String name;
  final String? email; // null for students (student auth uses username/pin)
  final String? phoneNumber;
  final String? address; // Admin/Instructor only
  final UserRole role;
  final List<String> assignedLevels; // Instructor only
  final List<String> searchKeywords; // Segmented array for Firestore search

  /// Student-specific fields (populated only for student roles).
  final String? levelId; // Student only
  final String? studentNumber; // e.g., "#1005"
  final String? username; // English-only username
  final String? pinCode; // e.g., "9575"
  final DateTime? lastActive; // Tracks online status

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
  });

  /// Returns true if the student was active within the last 5 minutes.
  bool get isOnline {
    if (lastActive == null) return false;
    return DateTime.now().difference(lastActive!).inMinutes < 5;
  }

  /// Returns a human-readable label for the student's last activity.
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
      userNumber: map['userNumber'] ?? 0,
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
      lastActive: map['lastActive'] != null
          ? DateTime.parse(map['lastActive'].toString())
          : null,
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
    };
  }
}

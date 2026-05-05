/// Data Tier — Repository
/// Path: lib/data/repositories/group_repository.dart
library;

import '../models/group_model.dart';

class GroupRepository {
  final List<GroupModel> _groups = [
    GroupModel(
      id: '1', serialNumber: 1, name: 'Morning Group A',
      instructorIds: ['#2'],
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      students: [
        GroupStudentEmbed(id: '#1001', name: 'Alex Rivera', level: 'l1', pin: '9575', lastActive: DateTime.now().subtract(const Duration(minutes: 2))),
        GroupStudentEmbed(id: '#1002', name: 'Maya Patel', level: 'l2', pin: '3812', lastActive: DateTime.now().subtract(const Duration(hours: 1, minutes: 20))),
        GroupStudentEmbed(id: '#1005', name: 'James Walker', level: 'l1', pin: '1489', lastActive: DateTime.now().subtract(const Duration(minutes: 1))),
      ],
    ),
    // Arabic group name — coexists with English names to test mixed RTL/LTR rendering
    GroupModel(
      id: '2', serialNumber: 2, name: 'المجموعة المسائية',
      instructorIds: ['#3'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      students: [
        GroupStudentEmbed(id: '#1001', name: 'Alex Rivera', level: 'l2', pin: '9575', lastActive: DateTime.now().subtract(const Duration(minutes: 2))),
        GroupStudentEmbed(id: '#1003', name: 'عمر حسان', level: 'l2', pin: '6204', lastActive: DateTime.now().subtract(const Duration(minutes: 45))),
      ],
    ),
    // Arabic group name — tests card layout when group title is RTL
    GroupModel(
      id: '3', serialNumber: 3, name: 'ورشة نهاية الأسبوع',
      instructorIds: ['#2', '#3'],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      students: [
        GroupStudentEmbed(id: '#1002', name: 'Maya Patel', level: 'l1', pin: '3812', lastActive: DateTime.now().subtract(const Duration(hours: 1, minutes: 20))),
        GroupStudentEmbed(id: '#1004', name: 'Lina Chen', level: 'l1', pin: '7731', lastActive: DateTime.now().subtract(const Duration(days: 2))),
        GroupStudentEmbed(id: '#1006', name: 'فاطمة الزهراء', level: 'l1', pin: '5923', lastActive: null),
      ],
    ),
    GroupModel(
      id: '4', serialNumber: 4, name: 'Advanced Cohort',
      instructorIds: ['#2'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      students: [
        GroupStudentEmbed(id: '#1001', name: 'Alex Rivera', level: 'l3', pin: '9575', lastActive: DateTime.now().subtract(const Duration(minutes: 2))),
        GroupStudentEmbed(id: '#1002', name: 'Maya Patel', level: 'l2', pin: '3812', lastActive: DateTime.now().subtract(const Duration(hours: 1, minutes: 20))),
        GroupStudentEmbed(id: '#1003', name: 'عمر حسان', level: 'l3', pin: '6204', lastActive: DateTime.now().subtract(const Duration(minutes: 45))),
      ],
    ),
  ];

  Future<List<GroupModel>> getGroups() async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch all groups (or filter by instructor if role-based).
    // Expected Output: List of GroupModel.
    await Future.delayed(const Duration(milliseconds: 500));
    return _groups;
  }

  Future<GroupModel?> getGroupById(String id) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Fetch a specific group by ID.
    // Expected Output: Single GroupModel or null.
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<GroupModel> createGroup(String name) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Create a new Group document.
    // Expected Output: Create and return a new GroupModel.
    await Future.delayed(const Duration(milliseconds: 300));
    final newGroup = GroupModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serialNumber: _groups.length + 1,
      name: name,
      instructorIds: [],
      students: [],
      createdAt: DateTime.now(),
    );
    _groups.add(newGroup);
    return newGroup;
  }

  Future<void> deleteGroup(String id) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Delete a specific group document.
    await Future.delayed(const Duration(milliseconds: 500));
    _groups.removeWhere((g) => g.id == id);
  }

  Future<void> updateGroup(String id, String newName) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Update the 'name' field of a specific group.
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _groups.indexWhere((g) => g.id == id);
    if (index != -1) {
      final old = _groups[index];
      _groups[index] = GroupModel(
        id: old.id,
        serialNumber: old.serialNumber,
        name: newName,
        instructorIds: old.instructorIds,
        students: old.students,
        createdAt: old.createdAt,
      );
    }
  }

  Future<void> addInstructorToGroup(String groupId, String instructorId) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Add an instructor ID to the group's 'instructorIds' array.
    await Future.delayed(const Duration(milliseconds: 300));
    final group = await getGroupById(groupId);
    if (group != null && !group.instructorIds.contains(instructorId)) {
      group.instructorIds.add(instructorId);
    }
  }

  Future<void> removeInstructorFromGroup(String groupId, String instructorId) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Remove an instructor ID from the group's 'instructorIds' array.
    await Future.delayed(const Duration(milliseconds: 300));
    final group = await getGroupById(groupId);
    if (group != null) {
      group.instructorIds.remove(instructorId);
    }
  }

  /// Adds a student embed to a group. Provide [name] and [pin] for a complete
  /// embed; in Phase 3 this data comes from the UserModel before the Firestore write.
  Future<void> addStudentToGroup(String groupId, String studentId, String levelId, {String name = '', String pin = ''}) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Add a GroupStudentEmbed object to the group's 'students' array.
    await Future.delayed(const Duration(milliseconds: 300));
    final group = await getGroupById(groupId);
    if (group != null && !group.studentIds.contains(studentId)) {
      group.students.add(GroupStudentEmbed(
        id: studentId,
        name: name.isNotEmpty ? name : studentId,
        level: levelId,
        pin: pin,
      ));
    }
  }

  Future<void> removeStudentFromGroup(String groupId, String studentId) async {
    // TODO: BACKEND_INTEGRATION - FIREBASE
    // Action: Remove a GroupStudentEmbed object from the group's 'students' array.
    await Future.delayed(const Duration(milliseconds: 300));
    final group = await getGroupById(groupId);
    if (group != null) {
      group.students.removeWhere((s) => s.id == studentId);
    }
  }
}

/// Logic Tier — Controller
/// Path: lib/logic/controllers/instructor_assignment_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/assignment_model.dart';
import '../../data/repositories/assignment_repository.dart';
import '../../di/service_locator.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class InstructorAssignmentController extends ChangeNotifier {
  final AssignmentRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AssignmentModel> _allAssignments = [];

  InstructorAssignmentController(this._repository) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _allAssignments = await _repository.getInstructorAssignments();
    _isLoading = false;
    notifyListeners();
  }

  // ── State ──────────────────────────────
  String _tab = 'active'; // 'active' or 'past'
  String _search = '';
  String _filter = 'all'; // 'all', 'overdue', 'central', 'custom'

  // ── Getters ────────────────────────────
  String get tab => _tab;
  String get search => _search;
  String get filter => _filter;

  List<AssignmentModel> get assignments {
    List<AssignmentModel> list = _allAssignments;

    // Tab filter
    if (_tab == 'active') {
      list = list.where((a) => a.isActive).toList();
    } else {
      list = list.where((a) => !a.isActive).toList();
    }

    // Chip filter
    switch (_filter) {
      case 'overdue':
        list = list.where((a) => a.isOverdue).toList();
        break;
      case 'central':
        list = list.where((a) => a.type == 'central').toList();
        break;
      case 'custom':
        list = list.where((a) => a.type == 'custom').toList();
        break;
    }

    // Search
    if (_search.isNotEmpty) {
      final term = _search.toLowerCase();
      list = list.where((a) => 
        a.title.toLowerCase().contains(term) || 
        (a.textContent?.toLowerCase().contains(term) ?? false)
      ).toList();
    }

    return list;
  }

  List<AssignmentModel> get allAssignments => _allAssignments;

  // ── Actions ────────────────────────────

  void switchTab(String tab) {
    _tab = tab;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setFilter(String value) {
    _filter = value;
    notifyListeners();
  }

  Future<void> addAssignment(
    String title, {
    DateTime? deadline,
    String? textContent,
    String type = 'custom',
    AssignmentType assignmentType = AssignmentType.text,
    List<String>? choices,
    String? groupId,
    String? groupName,
    String? levelId,
  }) async {
    if (title.isEmpty) return;
    
    // Check for active duplicates (same group, same level, and same title)
    final isDuplicate = _allAssignments.any((a) =>
        a.title.toLowerCase().trim() == title.toLowerCase().trim() &&
        a.groupId == groupId &&
        a.levelId == levelId &&
        a.isActive);
    if (isDuplicate) {
      throw Exception('This assignment is already active for this level in this group.');
    }

    _isLoading = true;
    notifyListeners();
    await _repository.addInstructorAssignment(
      title,
      deadline: deadline,
      textContent: textContent,
      type: type,
      assignmentType: assignmentType,
      choices: choices,
      groupId: groupId,
      groupName: groupName,
      levelId: levelId,
    );
    _allAssignments = await _repository.getInstructorAssignments();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteAssignment(String id) async {
    _isLoading = true;
    notifyListeners();
    await _repository.deleteAssignment(id);
    _allAssignments = await _repository.getInstructorAssignments();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateDeadline(String id, DateTime newDeadline) async {
    _isLoading = true;
    notifyListeners();
    await _repository.updateAssignmentDeadline(id, newDeadline);
    
    // Inject Mock Notification
    final notifRepo = getIt<NotificationRepository>();
    final assignment = _allAssignments.firstWhere((a) => a.id == id);
    await notifRepo.addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Assignment Updated',
      body: 'The deadline for "${assignment.title}" has been extended.',
      type: 'assignment',
      relatedId: id,
      isRead: false,
      time: 'Just now',
    ));

    _allAssignments = await _repository.getInstructorAssignments();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateContent(String id, String title, String textContent,
      AssignmentType assignmentType, List<String> choices,
      {String? groupId, String? groupName, String? levelId}) async {
    _isLoading = true;
    notifyListeners();
    await _repository.updateAssignmentContent(id, title, textContent, assignmentType, choices,
        groupId: groupId, groupName: groupName, levelId: levelId);
    
    // Inject Mock Notification
    final notifRepo = getIt<NotificationRepository>();
    final assignment = _allAssignments.firstWhere((a) => a.id == id);
    await notifRepo.addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Assignment Updated',
      body: 'The instructions for "${assignment.title}" have been updated.',
      type: 'assignment',
      relatedId: id,
      isRead: false,
      time: 'Just now',
    ));

    _allAssignments = await _repository.getInstructorAssignments();
    _isLoading = false;
    notifyListeners();
  }
}

/// Logic Tier — Controller
/// Path: lib/logic/controllers/audit_log_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/audit_log_model.dart';
import '../../data/repositories/audit_log_repository.dart';

class AuditLogController extends ChangeNotifier {
  final AuditLogRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AuditLog> _allLogs = [];

  AuditLogController(this._repository) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _allLogs = await _repository.getAllLogs();
    _isLoading = false;
    notifyListeners();
  }

  /// Reload logs from Firestore — called to refresh the list.
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    _allLogs = await _repository.getAllLogs();
    _isLoading = false;
    notifyListeners();
  }

  // ── State ──────────────────────────────
  String _search = '';
  String _roleFilter = 'all';
  String _timeFilter = 'all';
  String _categoryFilter = 'all';

  // ── Getters ────────────────────────────
  String get search => _search;
  String get roleFilter => _roleFilter;
  String get timeFilter => _timeFilter;
  String get categoryFilter => _categoryFilter;

  /// Role filter options for the UI chips.
  List<Map<String, String>> get roleFilters => const [
        {'label': 'All Roles', 'value': 'all'},
        {'label': 'Admin', 'value': 'admin'},
        {'label': 'Instructor', 'value': 'instructor'},
        {'label': 'Student', 'value': 'student'},
      ];

  /// Time filter options for the UI chips.
  List<Map<String, String>> get timeFilters => const [
        {'label': 'All Time', 'value': 'all'},
        {'label': 'Today', 'value': 'today'},
        {'label': '7 Days', 'value': '7days'},
        {'label': '30 Days', 'value': '30days'},
      ];

  /// Category filter options for the UI chips.
  List<Map<String, String>> get categoryFilters => const [
        {'label': 'All', 'value': 'all'},
        {'label': 'Users', 'value': 'users'},
        {'label': 'Groups', 'value': 'groups'},
        {'label': 'Curriculum', 'value': 'curriculum'},
        {'label': 'Assignments', 'value': 'assignments'},
        {'label': 'Grading', 'value': 'grading'},
        {'label': 'Submissions', 'value': 'submissions'},
      ];

  /// Filtered logs based on current search, role, time, and category filters.
  /// Search covers: action, performer name, details, and target person name.
  List<AuditLog> get filteredLogs {
    return _allLogs.where((log) {
      // Role filter
      final matchRole = _roleFilter == 'all' || log.performerRole == _roleFilter;

      // Category filter
      final matchCategory = _categoryFilter == 'all' || log.actionCategory == _categoryFilter;

      // Search — covers action, performer, details, and target
      final q = _search.toLowerCase();
      final matchSearch = q.isEmpty ||
          log.action.toLowerCase().contains(q) ||
          log.performerName.toLowerCase().contains(q) ||
          (log.details?.toLowerCase().contains(q) ?? false) ||
          (log.targetPersonName?.toLowerCase().contains(q) ?? false) ||
          (log.targetStudentNumber?.toLowerCase().contains(q) ?? false);

      // Time filter
      bool matchTime = true;
      if (_timeFilter != 'all') {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final logDay = DateTime(log.preciseTimestamp.year, log.preciseTimestamp.month, log.preciseTimestamp.day);
        final differenceInDays = today.difference(logDay).inDays;

        if (_timeFilter == 'today') {
          matchTime = logDay == today;
        } else if (_timeFilter == '7days') {
          matchTime = differenceInDays <= 7;
        } else if (_timeFilter == '30days') {
          matchTime = differenceInDays <= 30;
        }
      }

      return matchRole && matchCategory && matchSearch && matchTime;
    }).toList();
  }

  // ── Actions ────────────────────────────

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setRoleFilter(String value) {
    _roleFilter = value;
    notifyListeners();
  }

  void setTimeFilter(String value) {
    _timeFilter = value;
    notifyListeners();
  }

  void setCategoryFilter(String value) {
    _categoryFilter = value;
    notifyListeners();
  }
}

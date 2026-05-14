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

  // ── State ──────────────────────────────
  String _search = '';
  String _roleFilter = 'all';
  String _timeFilter = 'all';

  // ── Getters ────────────────────────────
  String get search => _search;
  String get roleFilter => _roleFilter;
  String get timeFilter => _timeFilter;

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

  /// Filtered logs based on current search, role, and time filter.
  List<AuditLog> get filteredLogs {
    return _allLogs.where((log) {
      final matchRole = _roleFilter == 'all' || log.performerRole == _roleFilter;
      final q = _search.toLowerCase();
      final matchSearch = q.isEmpty ||
          log.action.toLowerCase().contains(q) ||
          log.performerName.toLowerCase().contains(q);
          
      bool matchTime = true;
      if (_timeFilter != 'all') {
        final now = DateTime.now();
        final diff = now.difference(log.preciseTimestamp);
        if (_timeFilter == 'today') {
          matchTime = diff.inDays == 0 && now.day == log.preciseTimestamp.day;
        } else if (_timeFilter == '7days') {
          matchTime = diff.inDays <= 7;
        } else if (_timeFilter == '30days') {
          matchTime = diff.inDays <= 30;
        }
      }

      return matchRole && matchSearch && matchTime;
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
}

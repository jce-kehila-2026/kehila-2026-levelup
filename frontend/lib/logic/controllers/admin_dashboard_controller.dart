/// Logic Tier — Controller
/// Path: lib/logic/controllers/admin_dashboard_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../data/models/audit_log_model.dart';
import '../../data/repositories/audit_log_repository.dart';

class AdminDashboardController extends ChangeNotifier {
  final AuditLogRepository _logRepository;

  AdminDashboardController(this._logRepository) {
    _init();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<AuditLog> _recentLogs = [];

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    _recentLogs = await _logRepository.getRecentLogs(count: 5);
    _isLoading = false;
    notifyListeners();
  }

  // ── Getters ────────────────────────────
  /// Dashboard statistics (mock aggregated data).
  Map<String, String> get stats => {
        'students': '124',
        'instructors': '8',
        'levels': '3',
        'groups': '12',
        'lessons': '45',
        'activeTasks': '5',
      };

  /// Recent audit logs for the dashboard preview.
  List<AuditLog> get recentLogs => _recentLogs;
}

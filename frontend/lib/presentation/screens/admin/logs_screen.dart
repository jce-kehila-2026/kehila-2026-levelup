/// Presentation Tier — Screen
/// Path: lib/presentation/screens/admin/logs_screen.dart
///
///  Zero business logic — search, filter, and log retrieval via AuditLogController
///  Zero mock data — logs from AuditLogRepository via controller
///  Uses ListenableBuilder for reactivity
library;

import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/audit_log_item.dart';
import '../../../logic/controllers/audit_log_controller.dart';
import '../../../di/service_locator.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final AuditLogController _controller = getIt<AuditLogController>();

  String _localizedRoleLabel(String value, AppLocalizations l10n) {
    switch (value) {
      case 'admin': return l10n.filterRoleAdmin;
      case 'instructor': return l10n.roleInstructor;
      case 'student': return l10n.studentRoleLabel;
      default: return l10n.allRoles;
    }
  }

  String _localizedTimeLabel(String value, AppLocalizations l10n) {
    switch (value) {
      case 'today': return l10n.filterTimeToday;
      case '7days': return l10n.filterTime7Days;
      case '30days': return l10n.filterTime30Days;
      default: return l10n.allTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final l10n = AppLocalizations.of(context)!;
        final filteredLogs = _controller.filteredLogs;
        final roleFilters = _controller.roleFilters;
        final timeFilters = _controller.timeFilters;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(width: 3, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.auditLogsTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(AppLocalizations.of(context)!.entriesCount((filteredLogs.length).toString()), style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFc4b8da), width: 1.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 15, color: AppColors.mutedForeground),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (val) => _controller.setSearch(val),
                            decoration: InputDecoration(hintText: AppLocalizations.of(context)!.searchActionsUsers,
                              border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (_controller.search.isNotEmpty)
                          GestureDetector(
                            onTap: () => _controller.setSearch(''),
                            child: const Icon(Icons.close, size: 15, color: AppColors.mutedForeground),
                          ),
                      ],
                    ),
                  ),
                ),

                // Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      // Role Filter
                      PopupMenuButton<String>(
                        onSelected: (val) => _controller.setRoleFilter(val),
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Text(_localizedRoleLabel(_controller.roleFilter, l10n), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.mutedForeground),
                            ],
                          ),
                        ),
                        itemBuilder: (context) {
                          return roleFilters.map((f) => PopupMenuItem<String>(
                            value: f['value'],
                            child: Text(_localizedRoleLabel(f['value'] ?? '', l10n), style: const TextStyle(fontSize: 13)),
                          )).toList();
                        },
                      ),
                      const SizedBox(width: 12),
                      
                      // Time Filter
                      PopupMenuButton<String>(
                        onSelected: (val) => _controller.setTimeFilter(val),
                        color: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Text(_localizedTimeLabel(_controller.timeFilter, l10n), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.mutedForeground),
                            ],
                          ),
                        ),
                        itemBuilder: (context) {
                          return timeFilters.map((f) => PopupMenuItem<String>(
                            value: f['value'],
                            child: Text(_localizedTimeLabel(f['value'] ?? '', l10n), style: const TextStyle(fontSize: 13)),
                          )).toList();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // List
                Expanded(
                  child: Container(
                    margin: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filteredLogs.length,
                      itemBuilder: (context, index) {
                        return AuditLogItem(log: filteredLogs[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

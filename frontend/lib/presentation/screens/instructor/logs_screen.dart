/// Presentation Tier — Screen
/// Path: lib/presentation/screens/instructor/logs_screen.dart
///
/// ✅ Rich instructor-specific logs with action icons
/// ✅ Search by action, person name, student number
/// ✅ Filter chips for action categories
/// ✅ Smooth scroll physics and polished padding
library;

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/audit_log_item.dart';
import '../../widgets/empty_state.dart';
import '../../../logic/controllers/instructor_log_controller.dart';
import '../../../di/service_locator.dart';
import 'package:frontend/l10n/app_localizations.dart';

class InstructorLogsScreen extends StatefulWidget {
  const InstructorLogsScreen({super.key});

  @override
  State<InstructorLogsScreen> createState() => _InstructorLogsScreenState();
}

class _InstructorLogsScreenState extends State<InstructorLogsScreen> {
  final InstructorLogController _controller = getIt<InstructorLogController>();
  String _categoryFilter = 'all';

  static const Map<String, String> _categories = {
    'all': 'All',
    'graded': 'Grading',
    'student': 'Students',
    'assignment': 'Assignments',
    'curriculum': 'Curriculum',
  };

  List<dynamic> _applyCategory(List<dynamic> logs) {
    if (_categoryFilter == 'all') return logs;
    return logs.where((log) {
      final action = log.action.toLowerCase();
      final details = (log.details ?? '').toLowerCase();
      switch (_categoryFilter) {
        case 'graded':
          return action.contains('graded') || action.contains('revised') || action.contains('grade');
        case 'student':
          return action.contains('student') || action.contains('pin') || action.contains('joined');
        case 'assignment':
          return action.contains('assignment') || action.contains('assigned from') || action.contains('submitted');
        case 'curriculum':
          return action.contains('level') || action.contains('curriculum') || details.contains('content');
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final allFiltered = _controller.filteredLogs;
        final logs = _applyCategory(allFiltered);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 3, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.activityLabel, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                      ]),
                      const SizedBox(height: 4),
                      Text(AppLocalizations.of(context)!.countTotalShown(allFiltered.length.toString(), logs.length.toString()), style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                    ])),
                  ]),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFc4b8da), width: 1.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(children: [
                      const Icon(Icons.search, size: 15, color: AppColors.mutedForeground),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(onChanged: (val) => _controller.setSearch(val), decoration: InputDecoration(hintText: AppLocalizations.of(context)!.searchByActionName, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)), style: const TextStyle(fontSize: 14))),
                      if (_controller.search.isNotEmpty) GestureDetector(onTap: () => _controller.setSearch(''), child: const Icon(Icons.close, size: 15, color: AppColors.mutedForeground)),
                    ]),
                  ),
                ),

                // Category filter chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final key = _categories.keys.elementAt(index);
                        final l10n = AppLocalizations.of(context)!;
                        final label = switch (key) {
                          'all' => l10n.categoryAll,
                          'graded' => l10n.categoryGrading,
                          'student' => l10n.categoryStudents,
                          'assignment' => l10n.categoryAssignments,
                          'curriculum' => l10n.categoryCurriculum,
                          _ => key,
                        };
                        final isSelected = _categoryFilter == key;
                        return GestureDetector(
                          onTap: () => setState(() => _categoryFilter = key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: 1.5),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
                                  : [],
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : AppColors.mutedForeground,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // List
                Expanded(
                  child: logs.isEmpty
                      ? EmptyState(icon: Icons.history_toggle_off, title: AppLocalizations.of(context)!.noActivityFound, subtitle: AppLocalizations.of(context)!.tryAdjustingSearch)
                      : Container(
                          margin: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            itemCount: logs.length,
                            itemBuilder: (context, index) => AuditLogItem(log: logs[index]),
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

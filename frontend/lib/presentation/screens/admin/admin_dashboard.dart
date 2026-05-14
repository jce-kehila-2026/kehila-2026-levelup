import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/audit_log_item.dart';
import '../../../logic/controllers/admin_dashboard_controller.dart';
import '../../../di/service_locator.dart';
import 'package:frontend/l10n/app_localizations.dart';

class AdminDashboard extends StatelessWidget {
  final VoidCallback onNavigateToCurriculum;
  final VoidCallback onNavigateToUsers;
  final VoidCallback onNavigateToGroups;
  final VoidCallback onNavigateToLogs;

  const AdminDashboard({
    super.key,
    required this.onNavigateToCurriculum,
    required this.onNavigateToUsers,
    required this.onNavigateToGroups,
    required this.onNavigateToLogs,
  });

  Widget _buildStatTile(String label, String value, IconData icon, Color accent) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: accent),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = getIt<AdminDashboardController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final stats = controller.stats;
        final recentLogs = controller.recentLogs;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.welcomeBack, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                        const SizedBox(height: 2),
                        Text(l10n.roleAdministrator, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  // Quick Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onNavigateToCurriculum,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.text,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                              shadowColor: AppColors.accent.withValues(alpha: 0.35),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.menu_book, size: 14),
                                const SizedBox(width: 5),
                                Flexible(child: Text(l10n.navCurriculum, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onNavigateToUsers,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 4,
                              shadowColor: AppColors.primary.withValues(alpha: 0.25),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people, size: 14),
                                const SizedBox(width: 5),
                                Flexible(child: Text(l10n.navUsers, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onNavigateToGroups,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.how_to_reg, size: 14),
                                const SizedBox(width: 5),
                                Flexible(child: Text(l10n.navGroups, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Stats
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 10),
                        Text(l10n.platformOverview, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 0.6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildStatTile(l10n.statStudents, stats['students']!, Icons.people, AppColors.primary),
                            _buildStatTile(l10n.statInstructors, stats['instructors']!, Icons.work, AppColors.accent),
                            _buildStatTile(l10n.statLevels, stats['levels']!, Icons.layers, const Color(0xFF8B5CF6)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatTile(l10n.statGroups, stats['groups']!, Icons.how_to_reg, AppColors.success),
                            _buildStatTile(l10n.statLessons, stats['lessons']!, Icons.menu_book, AppColors.info),
                            _buildStatTile(l10n.statActiveTasks, stats['activeTasks']!, Icons.check_box, AppColors.warning),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Recent Activity
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 10),
                        Expanded(child: Text(l10n.recentActivity, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 0.6))),
                        GestureDetector(
                          onTap: onNavigateToLogs,
                          child: Row(
                            children: [
                              Text(l10n.seeAll, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                              const SizedBox(width: 2),
                              const Icon(Icons.chevron_right, size: 14, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: recentLogs.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(child: Text(l10n.noRecentActivity, style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13))),
                          )
                        : Column(
                            children: recentLogs.map((log) => AuditLogItem(log: log)).toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

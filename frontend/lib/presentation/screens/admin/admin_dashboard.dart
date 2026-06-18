import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/audit_log_item.dart';
import '../../../logic/controllers/admin_dashboard_controller.dart';
import '../../../di/service_locator.dart';
import 'package:frontend/l10n/app_localizations.dart';

// ── Design tokens — shared with admin_statistics_screen ──────────────────────

const _kBg            = Color(0xFFF8F9FA);
const _kPurplePrimary = Color(0xFF663D99);
const _kDivider       = Color(0xFFE2E8F0);
const _kTextMuted     = Color(0xFF64748B);

const _kShadow = BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 12,
  spreadRadius: 0,
  offset: Offset(0, 4),
);

// ─────────────────────────────────────────────────────────────────────────────

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

  // ── Hero banner ─────────────────────────────────────────────────────────────

  Widget _buildHeroBanner(BuildContext context, AppLocalizations l10n) {
    final dateLabel = DateFormat('EEEE, MMMM d').format(DateTime.now());
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Welcome text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeBack,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.roleAdministrator,
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Date + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'System Online',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section header — matches admin_statistics_screen style ──────────────────

  Widget _buildSectionHeader(String text, {Widget? trailing}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _kPurplePrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Divider(color: _kDivider, thickness: 1, height: 1),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing,
        ],
      ],
    );
  }

  // ── Platform Overview card ──────────────────────────────────────────────────

  Widget _buildConsolidatedCard(
    String title,
    IconData headerIcon,
    List<({String label, String value, VoidCallback onTap})> items,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(headerIcon, size: 20, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  for (int i = 0; i < items.length; i++) ...[
                    if (i > 0)
                      Container(
                        width: 1,
                        height: 44,
                        color: AppColors.border,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    Expanded(
                      child: InkWell(
                        onTap: items[i].onTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: _buildStatColumn(items[i].value, items[i].label),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = getIt<AdminDashboardController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Scaffold(
            backgroundColor: _kBg,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final stats = controller.stats;
        final recentLogs = controller.recentLogs;

        return Scaffold(
          backgroundColor: _kBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── Hero banner ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _buildHeroBanner(context, l10n),
                  ),
                  const SizedBox(height: 32),

                  // ── Platform Overview ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionHeader(l10n.platformOverview),
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildConsolidatedCard(
                          'People & Users',
                          Icons.people_rounded,
                          [
                            (label: l10n.statStudents,    value: stats['students']!,    onTap: onNavigateToUsers),
                            (label: l10n.statInstructors, value: stats['instructors']!, onTap: onNavigateToUsers),
                            (label: l10n.statGroups,      value: stats['groups']!,      onTap: onNavigateToGroups),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildConsolidatedCard(
                          'Curriculum & Content',
                          Icons.layers_rounded,
                          [
                            (label: l10n.statLevels,      value: stats['levels']!,      onTap: onNavigateToCurriculum),
                            (label: l10n.statLessons,     value: stats['lessons']!,     onTap: onNavigateToCurriculum),
                            (label: l10n.statActiveTasks, value: stats['activeTasks']!, onTap: onNavigateToCurriculum),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Recent Activity ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionHeader(
                      l10n.recentActivity,
                      trailing: GestureDetector(
                        onTap: onNavigateToLogs,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.seeAll,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _kPurplePrimary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.chevron_right,
                              size: 14,
                              color: _kPurplePrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      boxShadow: [_kShadow],
                    ),
                    child: recentLogs.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(28),
                            child: Center(
                              child: Text(
                                l10n.noRecentActivity,
                                style: const TextStyle(
                                  color: _kTextMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: recentLogs
                                .map((log) => AuditLogItem(log: log))
                                .toList(),
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

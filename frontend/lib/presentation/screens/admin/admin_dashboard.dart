import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/audit_log_item.dart';
import '../../../logic/controllers/admin_dashboard_controller.dart';
import '../../../di/service_locator.dart';
import 'package:frontend/l10n/app_localizations.dart';

// ── Design tokens — anchored to the platform palette (AppColors) ─────────────

const _kBg            = AppColors.background;
const _kPurplePrimary = AppColors.primary;
const _kTextMuted     = AppColors.mutedForeground;

// One soft shadow used by every content card on this screen.
const _kShadow = BoxShadow(
  color: Color(0x0D000000), // ≈ 5 % black — matches the rest of the app
  blurRadius: 8,
  spreadRadius: 0,
  offset: Offset(0, 2),
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

  Widget _buildHeroBanner(
    BuildContext context,
    AppLocalizations l10n,
    int activeToday,
  ) {
    final dateLabel = DateFormat('EEEE, MMMM d').format(DateTime.now());
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
            AppColors.primaryDeep,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles — same depth treatment as student/instructor banners
          PositionedDirectional(
            end: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          PositionedDirectional(
            end: 30,
            bottom: -15,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(28),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Date + active-today
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
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$activeToday ${l10n.activeToday}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ───────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String text, {Widget? trailing}) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: _kPurplePrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
            letterSpacing: 0.6,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing,
        ],
      ],
    );
  }

  // ── Platform Overview card ──────────────────────────────────────────────────
  //
  // Two modes:
  //  • Per-stat tap targets (each cell navigates somewhere different) — pass
  //    items with their own onTap and leave onTapAll null.
  //  • Single button (whole card navigates to one place) — pass onTapAll; the
  //    individual cells are not tappable and a chevron hints it's one button.

  Widget _buildConsolidatedCard(
    String title,
    IconData headerIcon,
    List<({String label, String value, VoidCallback? onTap})> items, {
    VoidCallback? onTapAll,
  }) {
    final bool singleButton = onTapAll != null;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [_kShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapAll,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (singleButton)
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.mutedForeground,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        Container(
                          width: 1,
                          height: 44,
                          color: AppColors.border,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      Expanded(
                        child: singleButton
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: _buildStatColumn(
                                    items[i].value, items[i].label),
                              )
                            : InkWell(
                                onTap: items[i].onTap,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6),
                                  child: _buildStatColumn(
                                      items[i].value, items[i].label),
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
                    child: _buildHeroBanner(
                        context, l10n, controller.activeToday),
                  ),
                  const SizedBox(height: 28),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionHeader(
                      l10n.myOverview,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Curriculum & Content — one button to curriculum.
                        _buildConsolidatedCard(
                          l10n.curriculumContent,
                          Icons.layers_rounded,
                          [
                            (label: l10n.statLevels,      value: stats['levels']!,      onTap: null),
                            (label: l10n.statLessons,     value: stats['lessons']!,     onTap: null),
                          ],
                          onTapAll: onNavigateToCurriculum,
                        ),
                        const SizedBox(height: 14),
                        // People & Users — three separate destinations.
                        _buildConsolidatedCard(
                          l10n.peopleAndUsers,
                          Icons.people_rounded,
                          [
                            (label: l10n.statStudents,    value: stats['students']!,    onTap: onNavigateToUsers),
                            (label: l10n.statInstructors, value: stats['instructors']!, onTap: onNavigateToUsers),
                            (label: l10n.statGroups,      value: stats['groups']!,      onTap: onNavigateToGroups),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Assignments — one button to the assignments page.
                        _buildConsolidatedCard(
                          l10n.assignmentsTitle,
                          Icons.assignment_rounded,
                          [
                            (label: l10n.statTotal,         value: stats['totalAssignments']!, onTap: null),
                            (label: l10n.statusActive,      value: stats['activeTasks']!,      onTap: null),
                            (label: l10n.statPendingReview, value: stats['pendingReview']!,    onTap: null),
                          ],
                          onTapAll: () => context.go('/admin?tab=6'),
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
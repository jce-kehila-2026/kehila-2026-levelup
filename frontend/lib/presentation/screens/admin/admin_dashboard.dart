import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/audit_log_item.dart';
import '../../widgets/recent_activity_timeline.dart';
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

/// Stat-card trend pills have no real data source yet (no historical
/// snapshots are stored), so they're gated behind this flag and only ever
/// turned on locally for screenshots.
/// TODO: real trends require storing periodic count snapshots in Firestore
/// (e.g. a daily 'stats_history' doc) and computing deltas.
const bool kShowDemoTrends = false;

const Map<String, int> _demoTrends = {
  'students': 12,
  'instructors': 8,
  'groups': 5,
  'levels': 3,
  'lessons': 15,
  'totalAssignments': 9,
};

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
          Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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

  // ── Stat cards (6, responsive grid) ─────────────────────────────────────────

  Widget _buildStatCard(
    AppLocalizations l10n, {
    required IconData icon,
    required String value,
    required String label,
    required bool gold,
    required int demoTrendPercent,
    VoidCallback? onTap,
  }) {
    final iconColor = gold ? AppColors.accent : AppColors.primary;
    final iconBg = gold ? AppColors.accent.withValues(alpha: 0.15) : AppColors.secondary;

    return Container(
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, size: 20, color: iconColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.text)),
                          Text(
                            label,
                            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (kShowDemoTrends) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_upward, size: 10, color: AppColors.success),
                            const SizedBox(width: 2),
                            Text(
                              '+$demoTrendPercent%',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(l10n.fromLastMonth, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, AppLocalizations l10n, Map<String, String> stats) {
    final cardsData = <({IconData icon, String value, String label, bool gold, VoidCallback? onTap})>[
      (icon: Icons.people, value: stats['students']!, label: l10n.statStudents, gold: false, onTap: onNavigateToUsers),
      (icon: Icons.school, value: stats['instructors']!, label: l10n.statInstructors, gold: true, onTap: onNavigateToUsers),
      (icon: Icons.groups, value: stats['groups']!, label: l10n.statGroups, gold: false, onTap: onNavigateToGroups),
      (icon: Icons.menu_book, value: stats['levels']!, label: l10n.statLevels, gold: true, onTap: onNavigateToCurriculum),
      (icon: Icons.play_circle_fill, value: stats['lessons']!, label: l10n.statLessons, gold: false, onTap: onNavigateToCurriculum),
      (icon: Icons.assignment, value: stats['totalAssignments']!, label: l10n.assignmentsTitle, gold: true, onTap: () => context.go('/admin?tab=6')),
    ];
    const demoTrendKeys = ['students', 'instructors', 'groups', 'levels', 'lessons', 'totalAssignments'];

    final cards = [
      for (int i = 0; i < cardsData.length; i++)
        _buildStatCard(
          l10n,
          icon: cardsData[i].icon,
          value: cardsData[i].value,
          label: cardsData[i].label,
          gold: cardsData[i].gold,
          onTap: cardsData[i].onTap,
          demoTrendPercent: _demoTrends[demoTrendKeys[i]] ?? 0,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000 ? 3 : (constraints.maxWidth >= 700 ? 2 : 1);
        final rows = <Widget>[];
        for (int i = 0; i < cards.length; i += columns) {
          final rowCards = cards.sublist(i, (i + columns).clamp(0, cards.length));
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int j = 0; j < rowCards.length; j++) ...[
                  if (j > 0) const SizedBox(width: 14),
                  Expanded(child: rowCards[j]),
                ],
              ],
            ),
          );
          if (i + columns < cards.length) rows.add(const SizedBox(height: 14));
        }
        return Column(children: rows);
      },
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
                    child: _buildHeroBanner(context, l10n, controller.activeToday),
                  ),
                  const SizedBox(height: 28),

                  // ── Stat cards ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSectionHeader(l10n.myOverview),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildStatsGrid(context, l10n, stats),
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
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 700) {
                                return Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: RecentActivityTimeline(logs: recentLogs),
                                );
                              }
                              return Column(
                                children: recentLogs.map((log) => AuditLogItem(log: log)).toList(),
                              );
                            },
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

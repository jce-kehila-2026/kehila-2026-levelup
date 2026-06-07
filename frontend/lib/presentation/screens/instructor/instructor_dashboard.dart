/// Presentation Tier — Screen
/// Path: lib/presentation/screens/instructor/instructor_dashboard.dart
///
/// ✅ Zero mock data — stats, scope, assignments from InstructorDashboardController
/// ✅ Uses ListenableBuilder for reactivity
/// ✅ Clickable stat cards + redesigned Current Week section
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/assignment_card.dart';
import '../../../logic/controllers/instructor_dashboard_controller.dart';
import '../../../di/service_locator.dart';
import 'package:frontend/l10n/app_localizations.dart';

class InstructorDashboard extends StatelessWidget {
  final VoidCallback onNavigateToAssignments;
  final VoidCallback onNavigateToGroups;

  const InstructorDashboard({
    super.key,
    required this.onNavigateToAssignments,
    required this.onNavigateToGroups,
  });

  Widget _buildStatTile(String label, String value, IconData icon, Color accent, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(height: 10),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = getIt<InstructorDashboardController>();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final stats = controller.stats;
        final pending = controller.pendingReview;
        final activeAssignments = controller.activeAssignments;

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
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.welcomeBack, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                        const SizedBox(height: 2),
                        Text(AppLocalizations.of(context)!.roleInstructorLabel, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  // ── Current Week — Visually Striking Section ──
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 16),
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF663d99),
                          Color(0xFF422969),
                          Color(0xFF26266a),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles
                        PositionedDirectional(
                          end: -20,
                          top: -20,
                          child: Container(
                            width: 100, height: 100,
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
                            width: 60, height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.04),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.play_circle_filled, size: 14, color: AppColors.accent),
                                        const SizedBox(width: 4),
                                        Text(AppLocalizations.of(context)!.activeBadge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accent, letterSpacing: 1)),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                controller.scopeLabel,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pending Alert
                  if (pending > 0)
                    GestureDetector(
                      onTap: onNavigateToAssignments,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(AppLocalizations.of(context)!.submissionsWaitingReview(pending.toString()), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text))),
                            const Icon(Icons.arrow_forward, size: 14, color: AppColors.text),
                          ],
                        ),
                      ),
                    ),

                  // Quick Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onNavigateToAssignments,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.text, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4, shadowColor: AppColors.accent.withValues(alpha: 0.35)),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.edit_note, size: 14), const SizedBox(width: 6), Flexible(child: Text(AppLocalizations.of(context)!.dashboardAssignments, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onNavigateToGroups,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4, shadowColor: AppColors.primary.withValues(alpha: 0.25)),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.people, size: 14), const SizedBox(width: 6), Flexible(child: Text(AppLocalizations.of(context)!.dashboardMyGroups, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Stats — Clickable
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 10),
                      Text(AppLocalizations.of(context)!.myOverview, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 0.6)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: [
                      _buildStatTile(AppLocalizations.of(context)!.statMyGroups, stats['myGroups']!, Icons.people, AppColors.primary,
                        onTap: onNavigateToGroups,
                      ),
                      _buildStatTile(AppLocalizations.of(context)!.statStudents, stats['students']!, Icons.person, AppColors.accent,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.navigatingToStudents), behavior: SnackBarBehavior.floating)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(children: [
                      _buildStatTile(AppLocalizations.of(context)!.dashboardAssignments, stats['assignments']!, Icons.check_box, const Color(0xFF8B5CF6),
                        onTap: onNavigateToAssignments,
                      ),
                      _buildStatTile(AppLocalizations.of(context)!.statPendingReview, stats['pendingReview']!, Icons.schedule, pending > 0 ? AppColors.warning : AppColors.success,
                        onTap: onNavigateToAssignments,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 28),

                  // Active Assignments
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [
                      Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 10),
                      Expanded(child: Text(AppLocalizations.of(context)!.activeAssignmentsHeader, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 0.6))),
                      GestureDetector(
                        onTap: onNavigateToAssignments,
                        child: Row(children: [
                          Text(AppLocalizations.of(context)!.seeAll, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          const SizedBox(width: 2),
                          const Icon(Icons.chevron_right, size: 14, color: AppColors.primary),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 100),
                    child: Column(
                      children: activeAssignments.map((a) => AssignmentCard(
                        title: a.title,
                        type: a.type,
                        isActive: a.isActive,
                        deadlineText: a.deadlineText,
                        isOverdue: a.isOverdue,
                        pendingCount: a.pendingCount,
                        gradedCount: a.gradedCount,
                        groupName: a.groupName,
                        onPress: () => context.push('/assignment/${a.id}'),
                      )).toList(),
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

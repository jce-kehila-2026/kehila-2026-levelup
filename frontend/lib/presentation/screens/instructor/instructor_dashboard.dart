/// Presentation Tier — Screen
/// Path: lib/presentation/screens/instructor/instructor_dashboard.dart
///
/// ✅ Zero mock data — stats, scope, assignments from InstructorDashboardController
/// ✅ Uses ListenableBuilder for reactivity
/// ✅ Clickable stat cards + redesigned Current Week section
library;

import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Widget _buildConsolidatedCard(
    String title,
    IconData headerIcon,
    List<({String label, String value})> items, {
    VoidCallback? onTap,
  }) {
    final content = Padding(
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
                  Container(width: 1, height: 44, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 4)),
                Expanded(child: _buildStatColumn(items[i].value, items[i].label)),
              ],
            ],
          ),
        ],
      ),
    );

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: content,
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
        final pending = int.tryParse(stats['pendingReview'] ?? '0') ?? 0;
        final activeAssignments = controller.activeAssignments;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Current Week — Visually Striking Section ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 14, 20, 16),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.welcomeBack,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.instructorName.isNotEmpty
                                          ? controller.instructorName
                                          : AppLocalizations.of(context)!.roleInstructorLabel,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
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
                    child: Column(children: [
                      _buildConsolidatedCard(
                        'My Classes',
                        Icons.how_to_reg,
                        [
                          (label: AppLocalizations.of(context)!.statMyGroups, value: stats['myGroups']!),
                          (label: AppLocalizations.of(context)!.statStudents, value: stats['students']!),
                        ],
                        onTap: onNavigateToGroups,
                      ),
                      const SizedBox(height: 12),
                      _buildConsolidatedCard(
                        'Workload',
                        Icons.check_box,
                        [
                          (label: AppLocalizations.of(context)!.dashboardAssignments, value: stats['assignments']!),
                          (label: AppLocalizations.of(context)!.statPendingReview, value: stats['pendingReview']!),
                        ],
                        onTap: onNavigateToAssignments,
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // Submissions Overview Pie Chart
                  _buildSubmissionsCard(context, controller),
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

  Widget _buildSubmissionsCard(BuildContext context, InstructorDashboardController controller) {
    final total = controller.totalSubmissions;
    final graded = controller.totalGraded;
    final pendingReview = controller.totalPendingReview;
    final correct = controller.totalCorrect;
    final incorrect = controller.totalIncorrect;
    final progress = total > 0 ? (graded / total) : 0.0;
    final pct = (progress * 100).toStringAsFixed(0);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.pie_chart_outline, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.gradingOverview, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
            ]),
            const SizedBox(height: 20),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100, height: 100,
                      child: CustomPaint(painter: _SubmissionsPiePainter(progress: progress)),
                    ),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('$pct%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                      Text(AppLocalizations.of(context)!.statTotal, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                    ]),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _infoRow(AppLocalizations.of(context)!.totalSubmissions, total.toString(), AppColors.primary, AppColors.primary),
                  const SizedBox(height: 8),
                  _infoRow(AppLocalizations.of(context)!.statPendingReview, pendingReview.toString(), AppColors.accent, AppColors.accent),
                  const SizedBox(height: 8),
                  _infoRow(AppLocalizations.of(context)!.gradedCorrectIndicator, correct.toString(), AppColors.success, AppColors.success),
                  const SizedBox(height: 8),
                  _infoRow(AppLocalizations.of(context)!.gradedIncorrectIndicator, incorrect.toString(), AppColors.destructive, AppColors.destructive),
                ])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, Color dotColor, Color valueColor) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground, fontWeight: FontWeight.w500))),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: valueColor)),
    ]);
  }
}

class _SubmissionsPiePainter extends CustomPainter {
  final double progress;
  _SubmissionsPiePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawCircle(center, radius, Paint()..color = AppColors.border..style = PaintingStyle.stroke..strokeWidth = strokeWidth);

    if (progress > 0) {
      final paint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -pi / 2, progress * 2 * pi, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SubmissionsPiePainter old) => old.progress != progress;
}

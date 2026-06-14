/// Presentation Tier — Screen
/// Path: lib/presentation/screens/student/student_dashboard.dart
///
///  Zero mock data — lessons, stats from StudentDashboardController
///  Uses ListenableBuilder for reactivity
library;

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../logic/controllers/student_dashboard_controller.dart';
import '../../../di/service_locator.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/l10n/app_localizations.dart';

class StudentDashboard extends StatefulWidget {
  final VoidCallback onNavigateToAssignments;
  final VoidCallback onNavigateToNotifications;

  const StudentDashboard({
    super.key,
    required this.onNavigateToAssignments,
    required this.onNavigateToNotifications,
  });

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final StudentDashboardController _controller = getIt<StudentDashboardController>();


  Widget _buildLessonCard(BuildContext context, dynamic lesson, int index) {
    final ghostNum = (index + 1).toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () => context.push('/lesson/${lesson.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Number badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ghostNum,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Lesson title
              Expanded(
                child: Text(
                  lesson.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Arrow
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward, size: 13, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final lessons = _controller.lessons;
        final l10n = AppLocalizations.of(context)!;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── GREETING BANNER ──
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 14, 20, 16),
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
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles
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
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.welcomeBack,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _controller.studentName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                                    ),
                                    child: Text(
                                      _controller.levelLabel,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                  if (_controller.groupLabel != '—' && _controller.groupLabel.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.group, size: 11, color: AppColors.accent),
                                          const SizedBox(width: 4),
                                          Text(
                                            _controller.groupLabel,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (_controller.instructorName != '—' && _controller.instructorName.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.person, size: 11, color: AppColors.accent),
                                          const SizedBox(width: 4),
                                          Text(
                                            _controller.instructorName,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.accent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── QUICK ACTIONS ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onNavigateToAssignments,
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
                                const Icon(Icons.edit_note, size: 14),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    l10n.navTasks,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── WORKLOAD OVERVIEW ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 18,
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.myOverview,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 0.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.check_box_outlined, size: 20, color: AppColors.accentDark),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Workload',
                                style: TextStyle(
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
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      '${_controller.tasksDue}',
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.navTasks,
                                      style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 44, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 4)),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      '${_controller.pendingReviewCount}',
                                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.text),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.statPendingReview,
                                      style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── SECTION HEADER ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 18,
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.lessonLibrary,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 0.6),
                        ),
                      ],
                    ),
                  ),

                  // ── LESSON LIST ──
                  if (lessons.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.menu_book, size: 28, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.noCurriculum,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: lessons.length,
                        itemBuilder: (context, index) => _buildLessonCard(context, lessons[index], index),
                      ),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

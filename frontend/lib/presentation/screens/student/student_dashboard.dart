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

  Widget _buildHeaderStat(
    IconData icon,
    String count,
    String label,
    VoidCallback? onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(height: 6),
            Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
            const SizedBox(height: 1),
            Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.mutedForeground), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, dynamic lesson, int index) {
    final ghostNum = (index + 1).toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () => context.push('/lesson/${lesson.id}'),
      child: Container(
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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ghostNum,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Lesson title — fills remaining space
                  Expanded(
                    child: Text(
                      lesson.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        height: 1.35,
                      ),
                    ),
                  ),
                  // Arrow — bottom-right
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.arrow_forward, size: 13, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
        ),
    );
  }

  @override
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // ── PREMIUM HEADER ──
                Container(
                  color: AppColors.secondary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Greeting row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.helloGreeting(_controller.studentName),
                                        style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _controller.levelLabel,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.30)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.school, size: 11, color: AppColors.accent),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_controller.instructorName} • ${_controller.groupLabel}',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.text),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Stat chips
                            Row(
                              children: [
                                Expanded(
                                  child: _buildHeaderStat(
                                    Icons.menu_book,
                                    _controller.lessonCount.toString(),
                                    l10n.lessonsSection,
                                    null,
                                    AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildHeaderStat(
                                    Icons.check_circle_outline,
                                    _controller.tasksDue.toString(),
                                    l10n.navTasks,
                                    widget.onNavigateToAssignments,
                                    AppColors.accent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildHeaderStat(
                                    Icons.notifications_outlined,
                                    _controller.newNotifications.toString(),
                                    l10n.navAlerts,
                                    widget.onNavigateToNotifications,
                                    AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(height: 1, color: AppColors.border),
                    ],
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
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
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
                    ),
                  )
                else
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: lessons.length,
                      itemBuilder: (context, index) => _buildLessonCard(context, lessons[index], index),
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

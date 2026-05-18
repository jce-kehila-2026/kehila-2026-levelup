/// Presentation Tier — Screen
/// Path: lib/presentation/screens/student/student_dashboard.dart
///
///  Zero mock data — lessons, stats from StudentDashboardController
///  Uses ListenableBuilder for reactivity
library;

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/lesson_card.dart';
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final lessons = _controller.lessons;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(AppLocalizations.of(context)!.helloGreeting(_controller.studentName), style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                          const SizedBox(height: 2),
                          Text(_controller.levelLabel, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withValues(alpha: 0.2))),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.school, size: 11, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('${_controller.instructorName} • ${_controller.groupLabel}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ]),
                      ),
                    ],
                  ),
                ),

                // Quick Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 14),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('${_controller.lessonCount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text, height: 1.1)),
                        Text(AppLocalizations.of(context)!.lessonsSection, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.mutedForeground)),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onNavigateToAssignments,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.text, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4, shadowColor: AppColors.accent.withValues(alpha: 0.35)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.check_circle_outline, size: 14),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.of(context)!.tasksDueCount(_controller.tasksDue.toString()), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onNavigateToNotifications,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4, shadowColor: AppColors.primary.withValues(alpha: 0.25)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.notifications, size: 14),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.of(context)!.newNotifCount(_controller.newNotifications.toString()), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    ),
                  ]),
                ),

                // Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 10),
                  child: Row(children: [
                    Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    Expanded(child: Text(AppLocalizations.of(context)!.lessonLibrary, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 0.6))),
                    Text(AppLocalizations.of(context)!.lessonsCountLabel(_controller.lessonCount.toString()), style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  ]),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFc4b8da), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))]),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(children: [
                      const Icon(Icons.search, size: 15, color: AppColors.mutedForeground),
                      const SizedBox(width: 8),
                      Expanded(child: TextField(onChanged: (val) => _controller.setSearch(val), decoration: InputDecoration(hintText: AppLocalizations.of(context)!.searchLessonsTopics, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 12)), style: const TextStyle(fontSize: 14))),
                      if (_controller.search.isNotEmpty) GestureDetector(onTap: () => _controller.setSearch(''), child: const Icon(Icons.close, size: 15, color: AppColors.mutedForeground)),
                    ]),
                  ),
                ),

                // List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 100),
                    itemCount: lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = lessons[index];
                      return LessonCard(
                        title: lesson.title,
                        searchTags: lesson.searchTags,
                        isVisible: lesson.visible,
                        showToggle: false,
                        onPress: () {
                          context.push('/lesson/${lesson.id}');
                        },
                      );
                    },
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

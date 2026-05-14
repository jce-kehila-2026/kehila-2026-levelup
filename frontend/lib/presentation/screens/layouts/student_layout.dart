import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/locale_toggle_button.dart';

import '../student/student_dashboard.dart';
import '../student/assignments_screen.dart';
import '../student/notifications_screen.dart';
import '../student/profile_screen.dart';


class StudentLayout extends StatefulWidget {
  const StudentLayout({super.key});

  @override
  State<StudentLayout> createState() => _StudentLayoutState();
}

class _StudentLayoutState extends State<StudentLayout> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    StudentDashboard(
      onNavigateToAssignments: () => setState(() => _currentIndex = 1),
      onNavigateToNotifications: () => setState(() => _currentIndex = 2),
    ),
    const StudentAssignmentsScreen(),
    StudentNotificationsScreen(
      onNavigateToLearn: () => setState(() => _currentIndex = 0),
    ),
    const StudentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        title: const Padding(
          padding: EdgeInsetsDirectional.only(start: 4),
          child: Text('Level', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
        ),
        actions: [
          const LocaleToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.mutedForeground,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.menu_book_outlined), activeIcon: const Icon(Icons.menu_book), label: AppLocalizations.of(context)!.navLearn),
            BottomNavigationBarItem(icon: const Icon(Icons.check_circle_outline), activeIcon: const Icon(Icons.check_circle), label: AppLocalizations.of(context)!.navTasks),
            BottomNavigationBarItem(
              icon: const Badge(child: Icon(Icons.notifications_none)),
              activeIcon: const Badge(child: Icon(Icons.notifications)),
              label: AppLocalizations.of(context)!.navAlerts,
            ),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: AppLocalizations.of(context)!.navProfile),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/locale_toggle_button.dart';

import '../instructor/instructor_dashboard.dart';
import '../instructor/groups_screen.dart';
import '../instructor/curriculum_screen.dart';
import '../instructor/assignments_screen.dart';
import '../instructor/logs_screen.dart';


class InstructorLayout extends StatefulWidget {
  const InstructorLayout({super.key});

  @override
  State<InstructorLayout> createState() => _InstructorLayoutState();
}

class _InstructorLayoutState extends State<InstructorLayout> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    InstructorDashboard(
      onNavigateToGroups: () => setState(() => _currentIndex = 1),
      onNavigateToAssignments: () => setState(() => _currentIndex = 3),
    ),
    const InstructorGroupsScreen(),
    const InstructorCurriculumScreen(),
    const InstructorAssignmentsScreen(),
    const InstructorLogsScreen(),
  ];

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        icon: const Icon(Icons.logout, size: 15, color: AppColors.mutedForeground),
        onPressed: () => context.go('/'),
      ),
    );
  }

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
          const SizedBox(width: 10),
          _buildLogoutButton(context),
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
            BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: AppLocalizations.of(context)!.navHome),
            BottomNavigationBarItem(icon: const Icon(Icons.how_to_reg_outlined), activeIcon: const Icon(Icons.how_to_reg), label: AppLocalizations.of(context)!.navGroups),
            BottomNavigationBarItem(icon: const Icon(Icons.menu_book_outlined), activeIcon: const Icon(Icons.menu_book), label: AppLocalizations.of(context)!.navMaterials),
            BottomNavigationBarItem(icon: const Icon(Icons.check_box_outlined), activeIcon: const Icon(Icons.check_box), label: AppLocalizations.of(context)!.navTasks),
            BottomNavigationBarItem(icon: const Icon(Icons.bar_chart_outlined), activeIcon: const Icon(Icons.bar_chart), label: AppLocalizations.of(context)!.navActivity),
          ],
        ),
      ),
    );
  }
}

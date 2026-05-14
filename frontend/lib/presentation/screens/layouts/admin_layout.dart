import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/locale_toggle_button.dart';

import '../admin/admin_dashboard.dart';
import '../admin/curriculum_screen.dart';
import '../admin/groups_screen.dart';
import '../admin/users_screen.dart';
import '../admin/logs_screen.dart';


class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    AdminDashboard(
      onNavigateToCurriculum: () => setState(() => _currentIndex = 1),
      onNavigateToUsers: () => setState(() => _currentIndex = 2),
      onNavigateToGroups: () => setState(() => _currentIndex = 3),
      onNavigateToLogs: () => setState(() => _currentIndex = 4),
    ),
    const CurriculumScreen(),
    const UsersScreen(),
    const GroupsScreen(),
    const LogsScreen(),
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
            BottomNavigationBarItem(icon: const Icon(Icons.menu_book_outlined), activeIcon: const Icon(Icons.menu_book), label: AppLocalizations.of(context)!.navCurriculum),
            BottomNavigationBarItem(icon: const Icon(Icons.people_outline), activeIcon: const Icon(Icons.people), label: AppLocalizations.of(context)!.navUsers),
            BottomNavigationBarItem(icon: const Icon(Icons.how_to_reg_outlined), activeIcon: const Icon(Icons.how_to_reg), label: AppLocalizations.of(context)!.navGroups),
            BottomNavigationBarItem(icon: const Icon(Icons.list_alt_outlined), activeIcon: const Icon(Icons.list_alt), label: AppLocalizations.of(context)!.navLogs),
          ],
        ),
      ),
    );
  }
}

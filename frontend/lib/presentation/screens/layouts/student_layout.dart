import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/locale_toggle_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../di/service_locator.dart';
import '../../../logic/controllers/auth_controller.dart';
import '../../../logic/controllers/student_notification_controller.dart';
import '../../../logic/controllers/student_dashboard_controller.dart';
import '../../../logic/controllers/student_assignment_controller.dart';

import '../student/student_dashboard.dart';
import '../student/assignments_screen.dart';
import '../student/notifications_screen.dart';
import '../student/profile_screen.dart';
import '../../widgets/golden_nav_icon.dart';


class StudentLayout extends StatefulWidget {
  const StudentLayout({super.key});

  @override
  State<StudentLayout> createState() => _StudentLayoutState();
}

class _StudentLayoutState extends State<StudentLayout> {
  bool _searchOpen = false;
  final TextEditingController _searchTextCtrl = TextEditingController();

  late final List<Widget> _screens = [
    StudentDashboard(
      onNavigateToAssignments:   () => context.go('/student?tab=1'),
      onNavigateToNotifications: () => context.go('/student?tab=2'),
    ),
    const StudentAssignmentsScreen(),
    StudentNotificationsScreen(
      onNavigateToHome: () => context.go('/student?tab=0'),
    ),
    const StudentProfileScreen(),
  ];

  @override
  void dispose() {
    _searchTextCtrl.dispose();
    super.dispose();
  }

  bool _hasSearch(int index) => const {0, 1}.contains(index);

  void _setSearch(String val) {
    final tabParam = GoRouterState.of(context).uri.queryParameters['tab'];
    final currentIndex = (int.tryParse(tabParam ?? '') ?? 0).clamp(0, 3);
    switch (currentIndex) {
      case 0:
        getIt<StudentDashboardController>().setSearch(val);
      case 1:
        getIt<StudentAssignmentController>().setSearch(val);
    }
  }

  void _closeSearch() {
    _searchTextCtrl.clear();
    _setSearch('');
    if (_searchOpen) setState(() => _searchOpen = false);
  }

  void _clearText() {
    _searchTextCtrl.clear();
    _setSearch('');
  }

  void _toggleSearch() {
    setState(() {
      if (_searchOpen) {
        _searchTextCtrl.clear();
        _setSearch('');
      }
      _searchOpen = !_searchOpen;
    });
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        icon: Icon(icon, size: 15, color: AppColors.mutedForeground),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabParam = GoRouterState.of(context).uri.queryParameters['tab'];
    final currentIndex = (int.tryParse(tabParam ?? '') ?? 0).clamp(0, 3);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        leading: _hasSearch(currentIndex)
          ? _searchOpen
            ? IconButton(
                icon: const Icon(Icons.arrow_back, size: 20, color: AppColors.mutedForeground),
                onPressed: _closeSearch,
              )
            : Center(
                child: Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsetsDirectional.only(start: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.search, size: 15, color: AppColors.mutedForeground),
                    onPressed: _toggleSearch,
                  ),
                ),
              )
          : null,
        leadingWidth: (!_searchOpen && _hasSearch(currentIndex)) ? 54 : null,
        centerTitle: true,
        title: _searchOpen
          ? TextField(
              controller: _searchTextCtrl,
              autofocus: true,
              onChanged: _setSearch,
              style: const TextStyle(fontSize: 15, color: AppColors.text),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.mutedForeground),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchTextCtrl,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.clear, size: 18, color: AppColors.mutedForeground),
                      onPressed: _clearText,
                    );
                  },
                ),
                suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            )
          : const Text('LevelUp', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
        actions: [
          const LocaleToggleButton(),
          const SizedBox(width: 6),
          _buildIconButton(
            icon: Icons.logout,
            onPressed: () async {
              getIt<AuthController>().reset();
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) {
            _closeSearch();
            context.go('/student?tab=$i');
          },
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.mutedForeground,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.home, active: false), activeIcon: const GoldenNavIcon(icon: Icons.home), label: AppLocalizations.of(context)!.navHome),
            BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.check_circle, active: false), activeIcon: const GoldenNavIcon(icon: Icons.check_circle), label: AppLocalizations.of(context)!.navTasks),
            BottomNavigationBarItem(
              icon: ListenableBuilder(
                listenable: getIt<StudentNotificationController>(),
                builder: (context, _) {
                  final count = getIt<StudentNotificationController>().unreadCount;
                  return Badge(
                    label: count > 0 ? Text('$count') : null,
                    isLabelVisible: count > 0,
                    child: const GoldenNavIcon(icon: Icons.notifications, active: false),
                  );
                },
              ),
              activeIcon: ListenableBuilder(
                listenable: getIt<StudentNotificationController>(),
                builder: (context, _) {
                  final count = getIt<StudentNotificationController>().unreadCount;
                  return Badge(
                    label: count > 0 ? Text('$count') : null,
                    isLabelVisible: count > 0,
                    child: const GoldenNavIcon(icon: Icons.notifications),
                  );
                },
              ),
              label: AppLocalizations.of(context)!.navAlerts,
            ),
            BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.person, active: false), activeIcon: const GoldenNavIcon(icon: Icons.person), label: AppLocalizations.of(context)!.navProfile),
          ],
        ),
      ),
    );
  }
}

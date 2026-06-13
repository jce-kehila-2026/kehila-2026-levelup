import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/locale_toggle_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../di/service_locator.dart';
import '../../../logic/controllers/auth_controller.dart';
import '../../../logic/controllers/student_notification_controller.dart';

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
  late final List<Widget> _screens = [
    StudentDashboard(
      onNavigateToAssignments:   () => context.go('/student?tab=1'),
      onNavigateToNotifications: () => context.go('/student?tab=2'),
    ),
    const StudentAssignmentsScreen(),
    StudentNotificationsScreen(
      onNavigateToLearn: () => context.go('/student?tab=0'),
    ),
    const StudentProfileScreen(),
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
        onPressed: () async {
          getIt<AuthController>().reset();
          await FirebaseAuth.instance.signOut();
          if (context.mounted) context.go('/login');
        },
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
          onTap: (i) => context.go('/student?tab=$i'),
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
              icon: ListenableBuilder(
                listenable: getIt<StudentNotificationController>(),
                builder: (context, _) {
                  final count = getIt<StudentNotificationController>().unreadCount;
                  return Badge(
                    label: count > 0 ? Text('$count') : null,
                    isLabelVisible: count > 0,
                    child: const Icon(Icons.notifications_none),
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
                    child: const Icon(Icons.notifications),
                  );
                },
              ),
              label: AppLocalizations.of(context)!.navAlerts,
            ),
            BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: AppLocalizations.of(context)!.navProfile),
          ],
        ),
      ),
    );
  }
}

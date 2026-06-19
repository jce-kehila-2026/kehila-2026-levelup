import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/locale_toggle_button.dart';
import '../../../di/service_locator.dart';
import '../../../logic/helpers/logout_helper.dart';
import '../../../logic/controllers/admin_statistics_controller.dart';
import '../../../logic/controllers/curriculum_controller.dart';
import '../../../logic/controllers/user_controller.dart';
import '../../../logic/controllers/group_controller.dart';
import '../../../logic/controllers/audit_log_controller.dart';

import '../admin/admin_dashboard.dart';
import '../admin/admin_statistics_screen.dart';
import '../admin/admin_assignments_screen.dart';
import '../admin/curriculum_screen.dart';
import '../admin/groups_screen.dart';
import '../admin/users_screen.dart';
import '../admin/logs_screen.dart';
import '../../widgets/golden_nav_icon.dart';


class AdminLayout extends StatefulWidget {
  const AdminLayout({super.key});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _searchOpen = false;
  final TextEditingController _searchTextCtrl = TextEditingController();

  late final List<Widget> _screens = [
    AdminDashboard(
      onNavigateToCurriculum: () => context.go('/admin?tab=1'),
      onNavigateToUsers:       () => context.go('/admin?tab=2'),
      onNavigateToGroups:      () => context.go('/admin?tab=3'),
      onNavigateToLogs:        () => context.go('/admin?tab=4'),
    ),
    const CurriculumScreen(),
    const UsersScreen(),
    const GroupsScreen(),
    const LogsScreen(),
    const AdminStatisticsScreen(),
    const AdminAssignmentsScreen(),
  ];

  @override
  void dispose() {
    _searchTextCtrl.dispose();
    super.dispose();
  }

  bool _hasSearch(int index) => const {1, 2, 3, 4}.contains(index);

  void _setSearch(String val) {
    final tabParam = GoRouterState.of(context).uri.queryParameters['tab'];
    final currentIndex = (int.tryParse(tabParam ?? '') ?? 0).clamp(0, 6);
    switch (currentIndex) {
      case 1:
        getIt<CurriculumController>().setSearch(val);
      case 2:
        getIt<UserController>().setSearch(val);
      case 3:
        getIt<GroupController>().setSearch(val);
        getIt<GroupController>().setArchiveSearch(val);
      case 4:
        getIt<AuditLogController>().setSearch(val);
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



  static const bool _enableResponsiveDesktopLayout = true;

  @override
  Widget build(BuildContext context) {
    final tabParam = GoRouterState.of(context).uri.queryParameters['tab'];
    final currentIndex = (int.tryParse(tabParam ?? '') ?? 0).clamp(0, 6);
    final bool isWide = _enableResponsiveDesktopLayout && MediaQuery.of(context).size.width > 850;

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
              await performLogout();
              if (context.mounted) context.go('/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: NavigationRail(
                    selectedIndex: currentIndex,
                    onDestinationSelected: (i) {
                      _closeSearch();
                      if (i == 5) getIt<AdminStatisticsController>().refresh();
                      context.go('/admin?tab=$i');
                    },
                    backgroundColor: AppColors.white,
                    selectedLabelTextStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: AppColors.primary),
                    unselectedLabelTextStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11, color: AppColors.mutedForeground),
                    indicatorColor: AppColors.secondary,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      NavigationRailDestination(
                        icon: const GoldenNavIcon(icon: Icons.home, active: false),
                        selectedIcon: const GoldenNavIcon(icon: Icons.home),
                        label: Text(AppLocalizations.of(context)!.navHome),
                      ),
                      NavigationRailDestination(
                        icon: const GoldenNavIcon(icon: Icons.menu_book, active: false),
                        selectedIcon: const GoldenNavIcon(icon: Icons.menu_book),
                        label: Text(AppLocalizations.of(context)!.navCurriculum),
                      ),
                      NavigationRailDestination(
                        icon: const GoldenNavIcon(icon: Icons.people, active: false),
                        selectedIcon: const GoldenNavIcon(icon: Icons.people),
                        label: Text(AppLocalizations.of(context)!.navUsers),
                      ),
                      NavigationRailDestination(
                        icon: const GoldenNavIcon(icon: Icons.how_to_reg, active: false),
                        selectedIcon: const GoldenNavIcon(icon: Icons.how_to_reg),
                        label: Text(AppLocalizations.of(context)!.navGroups),
                      ),
                      NavigationRailDestination(
                        icon: const GoldenNavIcon(icon: Icons.list_alt, active: false),
                        selectedIcon: const GoldenNavIcon(icon: Icons.list_alt),
                        label: Text(AppLocalizations.of(context)!.navLogs),
                      ),
                      NavigationRailDestination(
                        icon: const GoldenNavIcon(icon: Icons.bar_chart_rounded, active: false),
                        selectedIcon: const GoldenNavIcon(icon: Icons.bar_chart_rounded),
                        label: const Text('Stats'),
                      ),
                      NavigationRailDestination(
                        icon: const GoldenNavIcon(icon: Icons.assignment_rounded, active: false),
                        selectedIcon: const GoldenNavIcon(icon: Icons.assignment_rounded),
                        label: Text(AppLocalizations.of(context)!.assignmentsTitle),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, color: AppColors.border),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: IndexedStack(
                        index: currentIndex,
                        children: _screens,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : IndexedStack(
              index: currentIndex,
              children: _screens,
            ),
      bottomNavigationBar: isWide
          ? null
          : Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (i) {
                  _closeSearch();
                  if (i == 5) getIt<AdminStatisticsController>().refresh();
                  context.go('/admin?tab=$i');
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
                  BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.menu_book, active: false), activeIcon: const GoldenNavIcon(icon: Icons.menu_book), label: AppLocalizations.of(context)!.navCurriculum),
                  BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.people, active: false), activeIcon: const GoldenNavIcon(icon: Icons.people), label: AppLocalizations.of(context)!.navUsers),
                  BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.how_to_reg, active: false), activeIcon: const GoldenNavIcon(icon: Icons.how_to_reg), label: AppLocalizations.of(context)!.navGroups),
                  BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.list_alt, active: false), activeIcon: const GoldenNavIcon(icon: Icons.list_alt), label: AppLocalizations.of(context)!.navLogs),
                  BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.bar_chart_rounded, active: false), activeIcon: const GoldenNavIcon(icon: Icons.bar_chart_rounded), label: 'Stats'),
                  BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.assignment_rounded, active: false), activeIcon: const GoldenNavIcon(icon: Icons.assignment_rounded), label: AppLocalizations.of(context)!.assignmentsTitle),
                ],
              ),
            ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/locale_toggle_button.dart';
import '../../../di/service_locator.dart';
import '../../../logic/helpers/logout_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../logic/controllers/instructor_group_controller.dart';
import '../../../logic/controllers/curriculum_controller.dart';
import '../../../logic/controllers/instructor_assignment_controller.dart';
import '../../../logic/controllers/instructor_log_controller.dart';
import '../../../data/models/curriculum_model.dart';
import '../../../data/repositories/curriculum_repository.dart';

import '../instructor/instructor_dashboard.dart';
import '../instructor/groups_screen.dart';
import '../instructor/curriculum_screen.dart';
import '../instructor/assignments_screen.dart';
import '../instructor/logs_screen.dart';
import '../../widgets/golden_nav_icon.dart';


class InstructorLayout extends StatefulWidget {
  const InstructorLayout({super.key});

  @override
  State<InstructorLayout> createState() => _InstructorLayoutState();
}

class _InstructorLayoutState extends State<InstructorLayout> {
  bool _searchOpen = false;
  final TextEditingController _searchTextCtrl = TextEditingController();

  late final List<Widget> _screens = [
    InstructorDashboard(
      onNavigateToGroups:      () => context.go('/instructor?tab=1'),
      onNavigateToAssignments: () => context.go('/instructor?tab=3'),
    ),
    const InstructorGroupsScreen(),
    const InstructorCurriculumScreen(),
    const InstructorAssignmentsScreen(),
    const InstructorLogsScreen(),
  ];

  @override
  void dispose() {
    _searchTextCtrl.dispose();
    super.dispose();
  }

  bool _hasSearch(int index) => const {1, 2, 3, 4}.contains(index);

  void _setSearch(String val) {
    final tabParam = GoRouterState.of(context).uri.queryParameters['tab'];
    final currentIndex = (int.tryParse(tabParam ?? '') ?? 0).clamp(0, 4);
    switch (currentIndex) {
      case 1:
        getIt<InstructorGroupController>().setSearch(val);
      case 2:
        getIt<CurriculumController>().setSearch(val);
      case 3:
        getIt<InstructorAssignmentController>().setSearch(val);
      case 4:
        getIt<InstructorLogController>().setSearch(val);
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

  Future<void> _showProfileSheet() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    // Show loading indicator sheet first while fetching
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      final results = await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get(),
        getIt<CurriculumRepository>().getLevels(),
      ]);

      final doc = results[0] as DocumentSnapshot<Map<String, dynamic>>;
      final levels = results[1] as List<LevelModel>;

      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading sheet

      if (!doc.exists) return;

      final data = doc.data()!;
      final name = (data['displayName'] as String?) ?? (data['name'] as String?) ?? '—';
      final email = (data['email'] as String?) ?? firebaseUser.email ?? '—';
      final phone = (data['phoneNumber'] as String?) ?? '—';
      final location = (data['location'] as String?) ?? '—';
      final assignedLevelsRaw = (data['assignedLevels'] as List<dynamic>?)?.cast<String>() ?? [];

      final levelNames = assignedLevelsRaw.map((id) {
        final lvl = levels.where((l) => l.id == id).firstOrNull;
        return lvl?.name ?? id;
      }).join(', ');
      final displayLevels = levelNames.isNotEmpty ? levelNames : '—';

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.myProfile,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    const SizedBox(height: 16),
                    _readOnlyField(AppLocalizations.of(context)!.fullNameLabel, name),
                    const SizedBox(height: 12),
                    _readOnlyField(AppLocalizations.of(context)!.emailAddressLabel, email),
                    const SizedBox(height: 12),
                    _readOnlyField(AppLocalizations.of(context)!.phoneNumberLabel, phone),
                    const SizedBox(height: 12),
                    _readOnlyField('Location', location),
                    const SizedBox(height: 12),
                    _readOnlyField('Assigned Levels', displayLevels),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading sheet
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load profile: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Widget _readOnlyField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, color: AppColors.text)),
        ],
      ),
    );
  }

  static const bool _enableResponsiveDesktopLayout = true;

  @override
  Widget build(BuildContext context) {
    final tabParam = GoRouterState.of(context).uri.queryParameters['tab'];
    final currentIndex = (int.tryParse(tabParam ?? '') ?? 0).clamp(0, 4);
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
          _buildIconButton(icon: Icons.person_outline, onPressed: _showProfileSheet),
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
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (i) {
                    _closeSearch();
                    context.go('/instructor?tab=$i');
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
                      icon: const GoldenNavIcon(icon: Icons.how_to_reg, active: false),
                      selectedIcon: const GoldenNavIcon(icon: Icons.how_to_reg),
                      label: Text(AppLocalizations.of(context)!.navGroups),
                    ),
                    NavigationRailDestination(
                      icon: const GoldenNavIcon(icon: Icons.menu_book, active: false),
                      selectedIcon: const GoldenNavIcon(icon: Icons.menu_book),
                      label: Text(AppLocalizations.of(context)!.navMaterials),
                    ),
                    NavigationRailDestination(
                      icon: const GoldenNavIcon(icon: Icons.check_box, active: false),
                      selectedIcon: const GoldenNavIcon(icon: Icons.check_box),
                      label: Text(AppLocalizations.of(context)!.navTasks),
                    ),
                    NavigationRailDestination(
                      icon: const GoldenNavIcon(icon: Icons.bar_chart, active: false),
                      selectedIcon: const GoldenNavIcon(icon: Icons.bar_chart),
                      label: Text(AppLocalizations.of(context)!.navActivity),
                    ),
                  ],
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
                  context.go('/instructor?tab=$i');
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
                  BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.how_to_reg, active: false), activeIcon: const GoldenNavIcon(icon: Icons.how_to_reg), label: AppLocalizations.of(context)!.navGroups),
                  BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.menu_book, active: false), activeIcon: const GoldenNavIcon(icon: Icons.menu_book), label: AppLocalizations.of(context)!.navMaterials),
                  BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.check_box, active: false), activeIcon: const GoldenNavIcon(icon: Icons.check_box), label: AppLocalizations.of(context)!.navTasks),
                  BottomNavigationBarItem(icon: const GoldenNavIcon(icon: Icons.bar_chart, active: false), activeIcon: const GoldenNavIcon(icon: Icons.bar_chart), label: AppLocalizations.of(context)!.navActivity),
                ],
              ),
            ),
    );
  }
}

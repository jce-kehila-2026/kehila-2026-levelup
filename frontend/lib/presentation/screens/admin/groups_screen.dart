/// Presentation Tier — Screen
/// Path: lib/presentation/screens/admin/groups_screen.dart
///
/// ✅ Two tabs: Active Groups | Archived Groups
/// ✅ Archive tab: Restore + Permanently Delete actions
/// ✅ Zero business logic — via GroupController
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:frontend/l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/group_model.dart';
import '../../widgets/group_card.dart';
import '../../widgets/empty_state.dart';
import '../../../logic/controllers/group_controller.dart';
import '../../../di/service_locator.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> with SingleTickerProviderStateMixin {
  final GroupController _controller = getIt<GroupController>();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Always refresh on mount — GroupController is a singleton so data may be stale.
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.refresh());
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      // Always reload archive when switching to the Archive tab.
      if (_tabController.index == 1) {
        _controller.loadArchivedGroups();
      }
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  // ── Dialogs ────────────────────────────────────────────────────────────

  void _showAddGroupDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.group_add, color: AppColors.primary, size: 22),
            SizedBox(width: 10),
            Text('New Group', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create a new group', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Group Name',
                prefixIcon: const Icon(Icons.label_outline, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.input, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.mutedForeground)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              Navigator.pop(ctx);
              if (name.isNotEmpty) {
                try {
                  await _controller.createGroup(name);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Group "$name" created'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to create group: $e'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Create', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmArchiveGroup(GroupModel group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete ${group.name}?',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this group?\nStudents count: ${group.students.length}\nInstructors count: ${group.instructorIds.length}',
                style: const TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.archive_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'The group will be moved to the Archive tab and can be restored.',
                      style: TextStyle(fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel,
                style: const TextStyle(color: AppColors.mutedForeground)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _controller.deleteGroup(group.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${group.name}" moved to archive'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete group: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showArchivedGroupDetails(GroupModel group, int position) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (ctx) {
        final archivedDate = group.archivedAt != null
            ? 'Archived on: ${DateFormat('MMM d, y').format(group.archivedAt!)}'
            : 'Archived on: —';
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(group.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.mutedForeground.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Archived',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mutedForeground)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _detailRow(Icons.people_outline, 'Students', '${group.students.length}'),
              _detailRow(Icons.person_outline, 'Instructors', '${group.instructorIds.length}'),
              _detailRow(Icons.archive_outlined, 'Status', archivedDate),
              const SizedBox(height: 8),
              // Restore / Close
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('Close',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _controller.restoreGroup(group.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('"${group.name}" restored'),
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child:
                          const Text('Restore', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Permanently Delete (danger zone)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_forever, color: AppColors.error, size: 18),
                  label: const Text('Permanently Delete',
                      style: TextStyle(
                          color: AppColors.error, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _controller.permanentlyDeleteGroup(group.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('"${group.name}" permanently deleted'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.mutedForeground),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────

  Widget _buildSearchBar({required String hint, required ValueChanged<String> onChanged, required bool hasValue, required VoidCallback onClear}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFc4b8da), width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.search, size: 15, color: AppColors.mutedForeground),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            if (hasValue)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close, size: 15, color: AppColors.mutedForeground),
              ),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final l10n = AppLocalizations.of(context)!;
        final isArchiveTab = _tabController.index == 1;
        final groups = _controller.groups;
        final archivedGroups = _controller.archivedGroups;

        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: !isArchiveTab
              ? FloatingActionButton(
                  onPressed: _showAddGroupDialog,
                  backgroundColor: AppColors.primary,
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                )
              : null,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isArchiveTab ? 'Archived Groups' : l10n.groupsTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isArchiveTab
                                  ? '${archivedGroups.length} archived groups'
                                  : l10n.groupsCount(groups.length.toString()),
                              style: const TextStyle(
                                  fontSize: 13, color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Container(
                  color: AppColors.white,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.mutedForeground,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2,
                    labelStyle:
                        const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    unselectedLabelStyle:
                        const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    tabs: [
                      Tab(text: 'Active (${groups.length})'),
                      Tab(text: 'Archived (${archivedGroups.length})'),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ── Active Groups ──
                      Column(
                        children: [
                          _buildSearchBar(
                            hint: l10n.searchGroups,
                            onChanged: _controller.setSearch,
                            hasValue: _controller.search.isNotEmpty,
                            onClear: () => _controller.setSearch(''),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: groups.isEmpty
                                ? EmptyState(
                                    icon: Icons.how_to_reg,
                                    title: l10n.noGroupsFound,
                                    subtitle: l10n.tryDifferentSearch,
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsetsDirectional.only(
                                        start: 20, end: 20, bottom: 100),
                                    itemCount: groups.length,
                                    itemBuilder: (context, index) {
                                      final group = groups[index];
                                      final activeLevels = group.activeLevels;
                                      final levelLabel = activeLevels.isEmpty
                                          ? l10n.noLevelsAssigned
                                          : activeLevels
                                              .map((l) => l10n.levelLabel(
                                                  l.replaceAll('l', '')))
                                              .join(' · ');
                                      return Dismissible(
                                        key: ValueKey(group.id),
                                        direction: DismissDirection.endToStart,
                                        background: Container(
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          padding:
                                              const EdgeInsetsDirectional.only(
                                                  end: 20),
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: AppColors.error,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: const Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.archive,
                                                  color: AppColors.white),
                                              SizedBox(height: 2),
                                              Text('Archive',
                                                  style: TextStyle(
                                                      color: AppColors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        confirmDismiss: (_) async {
                                           _confirmArchiveGroup(group);
                                           return false;
                                         },
                                        child: GroupCard(
                                          groupName: group.name,
                                          instructorsCount:
                                              group.instructorIds.length,
                                          levelName: levelLabel,
                                          studentsCount: group.studentIds.length,
                                          onPress: () =>
                                              context.push('/group/${group.id}'),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),

                      // ── Archived Groups ──
                      Column(
                        children: [
                          _buildSearchBar(
                            hint: 'Search archived groups...',
                            onChanged: _controller.setArchiveSearch,
                            hasValue: _controller.archiveSearch.isNotEmpty,
                            onClear: () => _controller.setArchiveSearch(''),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: archivedGroups.isEmpty
                                ? const EmptyState(
                                    icon: Icons.archive_outlined,
                                    title: 'No archived groups',
                                    subtitle: 'Deleted groups will appear here',
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsetsDirectional.only(
                                        start: 20, end: 20, bottom: 100),
                                    itemCount: archivedGroups.length,
                                    itemBuilder: (context, index) {
                                      final group = archivedGroups[index];
                                      return _buildArchivedGroupCard(group, index + 1);
                                    },
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
        );
      },
    );
  }

  Widget _buildArchivedGroupCard(GroupModel group, int position) {
    final archivedDate = group.archivedAt != null
        ? DateFormat('MMM d, y').format(group.archivedAt!)
        : '—';

    return GestureDetector(
      onTap: () => _showArchivedGroupDetails(group, position),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.mutedForeground.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.group_outlined,
                  size: 22, color: AppColors.mutedForeground),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${group.students.length} students · ${group.instructorIds.length} instructors',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Archived $archivedDate',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mutedForeground.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            // Badge + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mutedForeground.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '#$position',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mutedForeground),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right,
                    size: 16, color: AppColors.mutedForeground),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

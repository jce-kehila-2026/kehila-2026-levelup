/// Presentation Tier — Screen
/// Path: lib/presentation/screens/admin/groups_screen.dart
///
/// ✅ Zero business logic — search and CRUD via GroupController
/// ✅ Zero mock data — group list from GroupRepository via controller
/// ✅ Uses ListenableBuilder for reactivity
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/group_card.dart';
import '../../widgets/empty_state.dart';
import '../../../logic/controllers/group_controller.dart';
import '../../../di/service_locator.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final GroupController _controller = getIt<GroupController>();

  void _confirmDeleteGroup(String groupId, String groupName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppLocalizations.of(context)!.deleteGroupTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
        content: Text(AppLocalizations.of(context)!.deleteGroupConfirmation(groupName), style: const TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: AppColors.mutedForeground))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              _controller.deleteGroup(groupId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.groupDeletedSuccess(groupName)), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
              );
            },
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
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
        final groups = _controller.groups;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header — NO Create button for Admin
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
                                Container(width: 3, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.groupsTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(AppLocalizations.of(context)!.groupsCount((groups.length).toString()), style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
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
                            onChanged: (val) => _controller.setSearch(val),
                            decoration: InputDecoration(hintText: AppLocalizations.of(context)!.searchGroups,
                              border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (_controller.search.isNotEmpty)
                          GestureDetector(
                            onTap: () => _controller.setSearch(''),
                            child: const Icon(Icons.close, size: 15, color: AppColors.mutedForeground),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // List
                Expanded(
                  child: groups.isEmpty
                      ? EmptyState(
                          icon: Icons.how_to_reg,
                          title: AppLocalizations.of(context)!.noGroupsFound,
                          subtitle: AppLocalizations.of(context)!.tryDifferentSearch,
                        )
                      : ListView.builder(
                          padding: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 100),
                          itemCount: groups.length,
                          itemBuilder: (context, index) {
                            final l10n = AppLocalizations.of(context)!;
                            final group = groups[index];
                            final levelMap = {'l1': l10n.levelLabel('1'), 'l2': l10n.levelLabel('2'), 'l3': l10n.levelLabel('3')};
                            final activeLevels = group.activeLevels;
                            final levelLabel = activeLevels.isEmpty
                                ? l10n.noLevelsAssigned
                                : activeLevels.map((l) => levelMap[l] ?? l).join(' · ');
                            return Dismissible(
                              key: ValueKey(group.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: AlignmentDirectional.centerEnd,
                                padding: const EdgeInsetsDirectional.only(end: 20),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete, color: AppColors.white),
                              ),
                              confirmDismiss: (_) async {
                                _confirmDeleteGroup(group.id, group.name);
                                return false; // We handle delete via the dialog
                              },
                              child: GroupCard(
                                serialNumber: group.serialNumber,
                                groupName: group.name,
                                instructorsCount: group.instructorIds.length,
                                levelName: levelLabel,
                                studentsCount: group.studentIds.length,
                                onPress: () => context.push('/group/${group.id}'),
                              ),
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

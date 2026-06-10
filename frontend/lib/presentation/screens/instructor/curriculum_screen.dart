/// Presentation Tier — Screen
/// Path: lib/presentation/screens/instructor/curriculum_screen.dart
///
/// ✅ Read-only browse of admin-approved curriculum content
/// ✅ Reuses CurriculumController, LessonCard, and AssignmentCard
/// ✅ Includes "Assign to Level" mechanism via bottom sheet
library;

import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/curriculum_model.dart';
import '../../../data/models/group_model.dart';
import '../../../logic/controllers/auth_controller.dart';
import '../../../logic/controllers/curriculum_controller.dart';
import '../../../logic/controllers/instructor_assignment_controller.dart';
import '../../../logic/controllers/instructor_group_controller.dart';
import '../../../di/service_locator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/lesson_card.dart';
import '../../widgets/assignment_card.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class InstructorCurriculumScreen extends StatefulWidget {
  const InstructorCurriculumScreen({super.key});

  @override
  State<InstructorCurriculumScreen> createState() => _InstructorCurriculumScreenState();
}

class _InstructorCurriculumScreenState extends State<InstructorCurriculumScreen> {
  final CurriculumController _controller = getIt<CurriculumController>();
  final InstructorAssignmentController _assignmentController = getIt<InstructorAssignmentController>();
  final InstructorGroupController _groupController = getIt<InstructorGroupController>();
  final AuthController _authController = getIt<AuthController>();

  List<String> _assignedLevelIds = [];

  @override
  void initState() {
    super.initState();
    _authController.getCurrentAssignedLevels().then((ids) {
      if (mounted) setState(() => _assignedLevelIds = ids);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Only levels this instructor is assigned to, with only visible items.
        final levels = _controller.levels
            .where((l) => _assignedLevelIds.contains(l.id))
            .map((l) => LevelModel(
                  id: l.id,
                  name: l.name,
                  weeks: l.weeks.map((w) => WeekModel(
                        id: w.id,
                        name: w.name,
                        items: w.items.where((i) => i.visible).toList(),
                      )).toList(),
                ))
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 3, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.materialsLabel, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 4),
                    Text(AppLocalizations.of(context)!.levelsAndBrowse(levels.length.toString()), style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                  ])),
                ]),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFc4b8da), width: 1.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(children: [
                    const Icon(Icons.search, size: 15, color: AppColors.mutedForeground),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(onChanged: (val) => _controller.setSearch(val), decoration: InputDecoration(hintText: AppLocalizations.of(context)!.searchMaterials, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)), style: const TextStyle(fontSize: 14))),
                    if (_controller.search.isNotEmpty) GestureDetector(onTap: () => _controller.setSearch(''), child: const Icon(Icons.close, size: 15, color: AppColors.mutedForeground)),
                  ]),
                ),
              ),
              const SizedBox(height: 6),

              // Level list
              Expanded(
                child: _controller.search.isNotEmpty
                  ? (_controller.searchResults.isEmpty
                      ? EmptyState(icon: Icons.search_off, title: AppLocalizations.of(context)!.noResults, subtitle: AppLocalizations.of(context)!.tryDifferentKeyword)
                      : ListView.builder(
                          padding: const EdgeInsetsDirectional.only(bottom: 100, top: 10, start: 16, end: 16),
                          itemCount: _controller.searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _controller.searchResults[index];
                            final item = result.item;
                            if (item.type == CurriculumItemType.material) {
                              return LessonCard(
                                title: item.title,
                                searchTags: [result.contextLabel, ...item.searchTags],
                                isVisible: item.visible,
                                showToggle: false,
                                onPress: () => context.push('/lesson/${item.id}'),
                                trailing: _buildAssignButton(item),
                              );
                            } else if (item.type == CurriculumItemType.assignment) {
                              return AssignmentCard(
                                title: item.title,
                                type: 'central',
                                isActive: item.isActive,
                                deadlineText: result.contextLabel,
                                isOverdue: false,
                                pendingCount: 0,
                                gradedCount: 0,
                                isAdminView: true,
                                onPress: () => context.push('/lesson/${item.id}'),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ))
                  : (levels.isEmpty
                      ? EmptyState(icon: Icons.menu_book, title: AppLocalizations.of(context)!.noCurriculum, subtitle: AppLocalizations.of(context)!.adminNotAddedCurriculum)
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: levels.length,
                          itemBuilder: (context, index) => _buildLevelBlock(index, levels[index]),
                        )),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildLevelBlock(int levelIndex, LevelModel level) {
    final isExpanded = _controller.isLevelExpanded(level.id);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(children: [
        GestureDetector(
          onTap: () => _controller.toggleLevel(level.id),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))]),
            child: Row(children: [
              Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Expanded(child: Text(level.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text))),
              Text('${level.weeks.length}w', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              const SizedBox(width: 10),
              Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 18, color: AppColors.mutedForeground),
            ]),
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsetsDirectional.only(top: 4, start: 12),
            padding: const EdgeInsetsDirectional.only(start: 12),
            decoration: const BoxDecoration(border: Border(left: BorderSide(color: AppColors.border, width: 2))),
            child: Column(children: [
              ...List.generate(level.weeks.length, (weekIndex) => _buildWeekBlock(levelIndex, weekIndex, level.weeks[weekIndex])),
            ]),
          ),
      ]),
    );
  }

  Widget _buildWeekBlock(int levelIndex, int weekIndex, WeekModel week) {
    final isExpanded = _controller.isWeekExpanded(week.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(children: [
        GestureDetector(
          onTap: () => _controller.toggleWeek(week.id),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border, width: 1))),
            child: Row(children: [
              Icon(isExpanded ? Icons.expand_more : Icons.chevron_right, size: 15, color: AppColors.mutedForeground),
              const SizedBox(width: 8),
              Expanded(child: Text(week.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text))),
              Text(AppLocalizations.of(context)!.itemsCount(week.items.length.toString()), style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
            ]),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(children: [
              ...List.generate(week.items.length, (itemIndex) {
                final item = week.items[itemIndex];
                if (item.type == CurriculumItemType.material) {
                  return LessonCard(
                    title: item.title,
                    searchTags: item.searchTags,
                    isVisible: item.visible,
                    showToggle: false,
                    onPress: () => context.push('/lesson/${item.id}'),
                    trailing: _buildAssignButton(item),
                  );
                } else if (item.type == CurriculumItemType.assignment) {
                  return AssignmentCard(
                    title: item.title,
                    type: 'central',
                    isActive: item.isActive,
                    deadlineText: item.deadlineText,
                    isOverdue: false,
                    pendingCount: 0,
                    gradedCount: 0,
                    isAdminView: true,
                    onPress: () => context.push('/lesson/${item.id}'),
                  );
                }
                return const SizedBox.shrink();
              }),
              if (week.items.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(AppLocalizations.of(context)!.noItemsYet, style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.mutedForeground)),
                ),
            ]),
          ),
      ]),
    );
  }

  Widget _buildAssignButton(CurriculumItem item) {
    return IconButton(
      onPressed: () => _showAssignMaterialDialog(item),
      icon: const Icon(Icons.assignment_add, size: 20, color: AppColors.primary),
      tooltip: AppLocalizations.of(context)!.assignToLevelTooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      splashRadius: 18,
    );
  }

  void _showAssignMaterialDialog(CurriculumItem item) {
    GroupModel? selectedGroup;
    LevelModel? selectedLevel;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Assign "${item.title}"',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<GroupModel>(
                decoration: InputDecoration(
                  labelText: 'Select Group',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _groupController.myGroups.map((g) => DropdownMenuItem(
                  value: g,
                  child: Text(g.name),
                )).toList(),
                onChanged: (val) => setDialogState(() => selectedGroup = val),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<LevelModel>(
                initialValue: selectedLevel,
                decoration: InputDecoration(
                  labelText: 'Select Level',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _controller.levels.map((l) => DropdownMenuItem(
                  value: l,
                  child: Text(l.name),
                )).toList(),
                onChanged: (val) => setDialogState(() => selectedLevel = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.mutedForeground)),
            ),
            ElevatedButton(
              onPressed: selectedGroup == null ? null : () async {
                final messenger = ScaffoldMessenger.of(context);
                final groupName = selectedGroup!.name;
                Navigator.pop(ctx);
                await _assignmentController.addAssignment(
                  item.title,
                  type: 'central',
                  groupId: selectedGroup!.id,
                  groupName: groupName,
                );
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('"${item.title}" assigned to $groupName'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Assign', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

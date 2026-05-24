/// Presentation Tier — Screen
/// Path: lib/presentation/screens/admin/curriculum_screen.dart
///
/// Proof-of-concept for the 3-Tier Architecture:
///   - No business logic here — every mutation (add level, add week, toggle
///     visibility, delete item) is delegated to [CurriculumController].
///   - No data declarations — the full curriculum tree comes from the
///     controller which sourced it from [CurriculumRepository].
///   - [ListenableBuilder] wraps the body so any controller.notifyListeners()
///     call triggers a reactive rebuild without setState.
///
/// Dialog helpers (_showAddLevelDialog, _showAddWeekDialog, etc.) are pure UI:
/// they collect user input from AlertDialogs and hand the result to the
/// controller. They do not mutate any state themselves.
// ignore_for_file: experimental_member_use
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../data/models/curriculum_model.dart';
import '../../../logic/controllers/curriculum_controller.dart';
import '../../../di/service_locator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/lesson_card.dart';
import '../../widgets/assignment_card.dart';
import 'material_editor_screen.dart';
import 'assignment_editor_screen.dart';

class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  // -- Injected Controller (from Logic Tier) ----------
  final CurriculumController _controller = getIt<CurriculumController>();

  // -- Dialog Helpers (pure UI — no state mutation) ---
  void _showAddLevelDialog() {
    String name = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(AppLocalizations.of(context)!.addLevelTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
        content: TextField(
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.levelNameLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          onChanged: (val) => name = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: AppColors.mutedForeground))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              _controller.addLevel(name);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.add, style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showAddWeekDialog(int levelIndex) {
    String name = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(AppLocalizations.of(context)!.addWeekTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
        content: TextField(
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.weekNameLabel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          onChanged: (val) => name = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: AppColors.mutedForeground))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              _controller.addWeek(levelIndex, name);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.add, style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  void _showAddMaterialDialog(int levelIndex, int weekIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MaterialEditorScreen(
          levelIndex: levelIndex,
          weekIndex: weekIndex,
        ),
      ),
    );
  }

  void _showAddAssignmentDialog(int levelIndex, int weekIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AssignmentEditorScreen(
          levelIndex: levelIndex,
          weekIndex: weekIndex,
        ),
      ),
    );
  }

  void _showEditMaterialSheet(int levelIndex, int weekIndex, int itemIndex, CurriculumItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => MaterialEditorScreen(
          levelIndex: levelIndex,
          weekIndex: weekIndex,
          itemIndex: itemIndex,
          item: item,
        ),
      ),
    );
  }

  void _showEditAssignmentSheet(int levelIndex, int weekIndex, int itemIndex, CurriculumItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AssignmentEditorScreen(
          levelIndex: levelIndex,
          weekIndex: weekIndex,
          itemIndex: itemIndex,
          item: item,
        ),
      ),
    );
  }

  void _showEditLevelDialog(int levelIndex, LevelModel level) {
    final nameCtrl = TextEditingController(text: level.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text('Edit Level', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.levelNameLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: AppColors.mutedForeground)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              _controller.editLevel(levelIndex, nameCtrl.text.trim());
              Navigator.pop(ctx);
            },
            child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteLevelDialog(int levelIndex, LevelModel level) async {
    final count = await _controller.getStudentCountForLevel(level.id);
    if (!mounted) return;

    final bool? confirmed;
    if (count == 0) {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Delete Level?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
          content: Text('Delete "${level.name}"? This cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: AppColors.mutedForeground))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.background,
          title: const Row(children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Warning', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error)),
          ]),
          content: Text(
            'There are $count student${count == 1 ? '' : 's'} assigned to this level. '
            'Deleting it will leave them unassigned.\n\nAre you absolutely sure you want to proceed?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: AppColors.mutedForeground))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete Anyway', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    if (confirmed == true) _controller.deleteLevel(levelIndex);
  }

  // -- Build ------------------------------------------
  @override
  Widget build(BuildContext context) {
    // ListenableBuilder reacts to notifyListeners() from the controller
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final levels = _controller.levels;

        return Scaffold(
          backgroundColor: AppColors.background,
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(width: 3, height: 20, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.curriculumTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(AppLocalizations.of(context)!.levelsCount((levels.length).toString()), style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddLevelDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.text,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          shadowColor: AppColors.accent.withValues(alpha: 0.3),
                        ),
                        icon: const Icon(Icons.add, size: 15),
                        label: Text(AppLocalizations.of(context)!.addLevelTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.searchLessonsTags,
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
                  child: levels.isEmpty
                      ? EmptyState(
                          icon: Icons.menu_book,
                          title: AppLocalizations.of(context)!.noLevelsYet,
                          subtitle: AppLocalizations.of(context)!.addFirstLevel,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: levels.length,
                          itemBuilder: (context, index) {
                            return _buildLevelBlock(index, levels[index]);
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

  Widget _buildLevelBlock(int levelIndex, LevelModel level) {
    final isExpanded = _controller.isLevelExpanded(level.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _controller.toggleLevel(level.id),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(level.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text))),
                  Text(AppLocalizations.of(context)!.weeksCount((level.weeks.length).toString()), style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18, color: AppColors.mutedForeground),
                    padding: EdgeInsets.zero,
                    onSelected: (val) {
                      if (val == 'edit') _showEditLevelDialog(levelIndex, level);
                      if (val == 'delete') _showDeleteLevelDialog(levelIndex, level);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppColors.error), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.error))])),
                    ],
                  ),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 18, color: AppColors.mutedForeground),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              margin: const EdgeInsetsDirectional.only(top: 4, start: 12),
              padding: const EdgeInsetsDirectional.only(start: 12),
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: AppColors.border, width: 2)),
              ),
              child: Column(
                children: [
                  ...List.generate(level.weeks.length, (weekIndex) {
                    return _buildWeekBlock(levelIndex, weekIndex, level.weeks[weekIndex]);
                  }),
                  GestureDetector(
                    onTap: () => _showAddWeekDialog(levelIndex),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(top: 4, bottom: 8, start: 8, end: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.add, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.of(context)!.addWeekTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeekBlock(int levelIndex, int weekIndex, WeekModel week) {
    final isExpanded = _controller.isWeekExpanded(week.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _controller.toggleWeek(week.id),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                children: [
                  Icon(isExpanded ? Icons.expand_more : Icons.chevron_right, size: 15, color: AppColors.mutedForeground),
                  const SizedBox(width: 8),
                  Expanded(child: Text(week.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text))),
                  Text(AppLocalizations.of(context)!.itemsCount((week.items.length).toString()), style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  ...List.generate(week.items.length, (itemIndex) {
                    final item = week.items[itemIndex];
                    if (item.type == CurriculumItemType.material) {
                      return LessonCard(
                        title: item.title,
                        searchTags: item.searchTags,
                        isVisible: item.visible,
                        showToggle: true,
                        onToggle: () => _controller.toggleVisibility(levelIndex, weekIndex, itemIndex),
                        onPress: () => context.push('/lesson/${item.id}'),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18, color: AppColors.mutedForeground),
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppColors.error), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.error))])),
                          ],
                          onSelected: (val) {
                            if (val == 'edit') _showEditMaterialSheet(levelIndex, weekIndex, itemIndex, item);
                            if (val == 'delete') _controller.deleteItem(levelIndex, weekIndex, itemIndex);
                          },
                        ),
                      );
                    } else if (item.type == CurriculumItemType.assignment) {
                      return AssignmentCard(
                        title: item.title,
                        type: 'central',
                        isAdminView: true,
                        isActive: item.isActive,
                        isVisible: item.visible,
                        showToggle: true,
                        onToggle: () => _controller.toggleVisibility(levelIndex, weekIndex, itemIndex),
                        deadlineText: item.deadlineText,
                        isOverdue: false,
                        pendingCount: 0,
                        gradedCount: 0,
                        onPress: () => context.push('/assignment/${item.id}', extra: 'admin'),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18, color: AppColors.mutedForeground),
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit')])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppColors.error), SizedBox(width: 8), Text('Delete', style: TextStyle(color: AppColors.error))])),
                          ],
                          onSelected: (val) {
                            if (val == 'edit') _showEditAssignmentSheet(levelIndex, weekIndex, itemIndex, item);
                            if (val == 'delete') _controller.deleteItem(levelIndex, weekIndex, itemIndex);
                          },
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  if (week.items.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(AppLocalizations.of(context)!.noItemsYet, style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.mutedForeground)),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showAddMaterialDialog(levelIndex, weekIndex),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add, size: 14),
                            label: Text(AppLocalizations.of(context)!.addMaterial, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddAssignmentDialog(levelIndex, weekIndex),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.text,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add, size: 14),
                            label: Text(AppLocalizations.of(context)!.addAssignment, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

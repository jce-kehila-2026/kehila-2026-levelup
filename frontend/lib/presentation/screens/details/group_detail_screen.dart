/// Presentation Tier — Screen
/// Path: lib/presentation/screens/details/group_detail_screen.dart
///
/// ✅ Zero mock data — uses GroupDetailController
/// ✅ Uses ListenableBuilder for reactivity
/// ✅ Students displayed hierarchically by academic level
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../../data/models/user_model.dart';
import '../../../logic/controllers/group_detail_controller.dart';
import '../../../di/service_locator.dart';
import 'package:frontend/l10n/app_localizations.dart';

class GroupDetailScreen extends StatefulWidget {
  final String id;
  const GroupDetailScreen({super.key, required this.id});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late final GroupDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = getIt<GroupDetailController>(param1: widget.id);
  }

  String _formatDate(DateTime dt, String locale) {
    return DateFormat('d MMM y', locale).format(dt);
  }

  String _localizedLastActive(DateTime? lastActive, AppLocalizations l10n) {
    if (lastActive == null) return l10n.timeNever;
    final diff = DateTime.now().difference(lastActive);
    if (diff.inMinutes < 5) return l10n.timeOnline;
    if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes.toString());
    if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours.toString());
    return l10n.timeAgoDays(diff.inDays.toString());
  }

  String _localizedLevelName(String levelId, AppLocalizations l10n) {
    switch (levelId) {
      case 'l1': return l10n.levelOneLabel;
      case 'l2': return l10n.levelTwoLabel;
      case 'l3': return l10n.levelThreeLabel;
      default: return GroupDetailController.levelMap[levelId] ?? levelId;
    }
  }

  // ── Dialogs ──────────────────────────────

  void _showAddInstructorDialog() {
    _controller.setAvailableInstructorsSearch('');
    showDialog(
      context: context,
      builder: (ctx) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final available = _controller.availableInstructors;
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(AppLocalizations.of(context)!.addInstructor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    _buildDialogSearchBar(
                      onChanged: _controller.setAvailableInstructorsSearch,
                      searchValue: _controller.availableInstructorsSearch,
                      onClear: () => _controller.setAvailableInstructorsSearch(''),
                    ),
                    Expanded(
                      child: available.isEmpty
                          ? Center(child: Text(AppLocalizations.of(context)!.noInstructorsFound, style: TextStyle(color: AppColors.mutedForeground)))
                          : ListView.builder(
                              itemCount: available.length,
                              itemBuilder: (context, index) {
                                final inst = available[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(inst.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(inst.email ?? '', style: const TextStyle(fontSize: 12)),
                                  trailing: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      minimumSize: const Size(60, 30),
                                    ),
                                    onPressed: () => _controller.addInstructor(inst.id),
                                    child: Text(AppLocalizations.of(context)!.addButton),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(context)!.closeButton, style: TextStyle(color: AppColors.mutedForeground)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddStudentDialog() {
    _controller.setAvailableStudentsSearch('');
    _controller.clearBulkSelection();
    String globalLevel = 'l1';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final available = _controller.availableStudents;
            final selCount = _controller.bulkSelectionCount;
            final l10n = AppLocalizations.of(context)!;
            final levelName = GroupDetailController.levelMap[globalLevel] ?? globalLevel;

            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(l10n.addStudent, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SizedBox(
                width: double.maxFinite,
                height: 460,
                child: Column(
                  children: [
                    // Create New Student card
                    GestureDetector(
                      onTap: () { Navigator.pop(ctx); _showCreateStudentDialog(); },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(children: [
                          Icon(Icons.person_add, size: 18, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(l10n.createNewStudent, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                            Text(l10n.generateCredentialsAuto, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                          ])),
                          Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                        ]),
                      ),
                    ),
                    // Global level dropdown
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Text(l10n.assignSelectedToLevel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
                          const Spacer(),
                          DropdownButton<String>(
                            value: globalLevel,
                            isDense: true,
                            underline: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(12),
                            icon: const Icon(Icons.expand_more, size: 16, color: AppColors.mutedForeground),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                            items: GroupDetailController.levelMap.entries.map((e) =>
                              DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              ),
                            ).toList(),
                            onChanged: (v) { if (v != null) setDialogState(() => globalLevel = v); },
                          ),
                        ],
                      ),
                    ),
                    _buildDialogSearchBar(
                      onChanged: _controller.setAvailableStudentsSearch,
                      searchValue: _controller.availableStudentsSearch,
                      onClear: () => _controller.setAvailableStudentsSearch(''),
                    ),
                    if (selCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.nSelected(selCount.toString()),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      child: available.isEmpty
                          ? Center(child: Text(l10n.noStudentsFound, style: TextStyle(color: AppColors.mutedForeground)))
                          : ListView.builder(
                              itemCount: available.length,
                              itemBuilder: (context, index) {
                                final student = available[index];
                                final isSelected = _controller.bulkSelectedStudentIds.contains(student.id);
                                return _BulkSelectStudentTile(
                                  student: student,
                                  isSelected: isSelected,
                                  onToggle: () => _controller.toggleBulkStudent(student.id),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.closeButton, style: TextStyle(color: AppColors.mutedForeground)),
                ),
                if (selCount > 0)
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _controller.bulkAddStudents(globalLevel);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(l10n.addNStudentsToLevel(selCount.toString(), levelName), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            );
          },
        ),
      ),
    ).whenComplete(() => _controller.clearBulkSelection());
  }

  void _showCreateStudentDialog() {
    final rows = [_CreateStudentRow()];
    String selectedLevel = 'l1';
    bool isCreating = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final l10n = AppLocalizations.of(context)!;

          bool validate() {
            bool valid = true;
            for (final row in rows) {
              row.nameError = null;
              row.usernameError = null;
              row.pinError = null;

              if (row.nameCtrl.text.trim().isEmpty) {
                row.nameError = 'Required';
                valid = false;
              }

              final u = row.usernameCtrl.text.trim();
              if (u.isEmpty) {
                row.usernameError = 'Required';
                valid = false;
              } else if (u.contains(' ') || u != u.toLowerCase()) {
                row.usernameError = 'Lowercase, no spaces';
                valid = false;
              }

              final pin = row.pinCtrl.text;
              if (pin.isEmpty) {
                row.pinError = 'Required';
                valid = false;
              } else if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
                row.pinError = 'Exactly 6 digits';
                valid = false;
              }
            }
            return valid;
          }

          return AlertDialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(children: [
              Icon(Icons.group_add, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(l10n.bulkCreateTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ]),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.assignToLevel,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: GroupDetailController.levelMap.entries.map((e) {
                      final sel = selectedLevel == e.key;
                      return Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: GestureDetector(
                          onTap: isCreating ? null : () => setDialogState(() => selectedLevel = e.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? AppColors.primary : AppColors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                            ),
                            child: Text(
                              e.value,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.mutedForeground),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: rows.asMap().entries.map((entry) {
                          final i = entry.key;
                          final row = entry.value;
                          return _buildStudentFormRow(
                            row: row,
                            canRemove: rows.length > 1,
                            enabled: !isCreating,
                            onRemove: () => setDialogState(() {
                              row.dispose();
                              rows.removeAt(i);
                            }),
                            onChange: () => setDialogState(() {}),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (!isCreating)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: TextButton.icon(
                        onPressed: () => setDialogState(() => rows.add(_CreateStudentRow())),
                        icon: const Icon(Icons.add, size: 15),
                        label: const Text('+ Add Another Student', style: TextStyle(fontSize: 13)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isCreating ? null : () {
                  for (final row in rows) { row.dispose(); }
                  Navigator.pop(ctx);
                },
                child: Text(l10n.cancelButton, style: TextStyle(color: AppColors.mutedForeground)),
              ),
              ElevatedButton(
                onPressed: isCreating ? null : () async {
                  if (!validate()) {
                    setDialogState(() {});
                    return;
                  }
                  // Duplicate username check
                  bool hasDupe = false;
                  for (final row in rows) {
                    final exists = await _controller.usernameExists(row.usernameCtrl.text.trim());
                    if (exists) {
                      row.usernameError = 'Username already taken';
                      hasDupe = true;
                    }
                  }
                  if (hasDupe) {
                    setDialogState(() {});
                    return;
                  }
                  setDialogState(() => isCreating = true);
                  try {
                    for (final row in rows) {
                      await _controller.createStudent(
                        row.nameCtrl.text.trim(),
                        selectedLevel,
                        username: row.usernameCtrl.text.trim(),
                        pinCode: row.pinCtrl.text.trim(),
                      );
                    }
                    final count = rows.length;
                    for (final row in rows) { row.dispose(); }
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                        content: Text(count == 1 ? 'Student created successfully' : '$count students created successfully'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  } catch (e) {
                    setDialogState(() => isCreating = false);
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                        content: Text('Failed to create student: $e'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 6),
                      ));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isCreating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        rows.length <= 1 ? l10n.createButton : l10n.createNStudents(rows.length.toString()),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudentFormRow({
    required _CreateStudentRow row,
    required bool canRemove,
    required bool enabled,
    required VoidCallback onRemove,
    required VoidCallback onChange,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.nameCtrl,
                  enabled: enabled,
                  onChanged: (_) => onChange(),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: row.nameError != null ? AppColors.error : AppColors.input),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    errorText: row.nameError,
                    errorStyle: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              if (canRemove) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: enabled ? onRemove : null,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14, color: AppColors.error),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: row.usernameCtrl,
                  enabled: enabled,
                  onChanged: (_) => onChange(),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'ali.hassan',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: row.usernameError != null ? AppColors.error : AppColors.input),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    errorText: row.usernameError,
                    errorStyle: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: row.pinCtrl,
                  enabled: enabled,
                  onChanged: (_) => onChange(),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    hintText: '123456',
                    counterText: '',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: row.pinError != null ? AppColors.error : AppColors.input),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    errorText: row.pinError,
                    errorStyle: const TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showResetPinDialog(UserModel student) {
    final newPin = _controller.resetStudentPin(student.id);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.lock_reset, size: 28, color: AppColors.accentDark),
          ),
          const SizedBox(height: 14),
          Text(AppLocalizations.of(context)!.pinResetTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(AppLocalizations.of(context)!.newPinForStudent(student.name), style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
            child: Text(newPin, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primaryDark, letterSpacing: 6)),
          ),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(AppLocalizations.of(context)!.doneButton, style: TextStyle(fontWeight: FontWeight.bold)),
          )),
        ]),
      ),
    );
  }

  /// Shared search bar widget used inside both Add dialogs.
  Widget _buildDialogSearchBar({
    required ValueChanged<String> onChanged,
    required String searchValue,
    required VoidCallback onClear,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFc4b8da), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 15, color: AppColors.mutedForeground),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(hintText: AppLocalizations.of(context)!.searchByNameUsername,
                border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14, color: AppColors.text),
            ),
          ),
          if (searchValue.isNotEmpty)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close, size: 15, color: AppColors.mutedForeground),
            ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final l10n = AppLocalizations.of(context)!;
        final locale = l10n.localeName;
        final group = _controller.group;
        final instructors = _controller.groupInstructors;
        final studentsByLevel = _controller.studentsByLevel;
        final totalStudents = _controller.allGroupStudents.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.text),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(AppLocalizations.of(context)!.groupDetails, style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: Text(AppLocalizations.of(context)!.deleteGroup, style: TextStyle(fontWeight: FontWeight.bold)),
                      content: Text(AppLocalizations.of(context)!.deleteGroupConfirm(group.name)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context)!.cancelButton, style: TextStyle(color: AppColors.mutedForeground))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await _controller.deleteGroup();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.groupDeleted(group.name)), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating));
                            }
                          },
                          child: Text(AppLocalizations.of(context)!.deleteButton, style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  // ── Hero Card ──
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('#${group.serialNumber} ${group.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.text)),
                                  const SizedBox(height: 6),
                                  // Level badges
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: group.activeLevels.map((levelId) {
                                      final label = _localizedLevelName(levelId, l10n);
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.people, size: 12, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text('$totalStudents', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: AppColors.mutedForeground),
                            const SizedBox(width: 6),
                            Text(l10n.createdOnLabel(_formatDate(group.createdAt, locale)), style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Instructors Section ──
                  _buildSectionHeader(l10n.instructorsSectionTitle, onAdd: _showAddInstructorDialog),

                  if (instructors.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(AppLocalizations.of(context)!.noInstructorsAssigned, style: TextStyle(color: AppColors.mutedForeground)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: instructors.length,
                      itemBuilder: (context, index) {
                        final inst = instructors[index];
                        return _buildUserCard(
                          user: inst,
                          avatarColor: AppColors.accent.withValues(alpha: 0.2),
                          avatarTextColor: AppColors.accentDark,
                          onRemove: () => _controller.removeInstructor(inst.id),
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  // ── Students Section ──
                  _buildSectionHeader(l10n.studentsSectionTitle, onAdd: _showAddStudentDialog),

                  // Search Bar + Level Filter
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
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
                                      hintText: AppLocalizations.of(context)!.searchByNameUsername,
                                      border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                        if (group.activeLevels.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFc4b8da), width: 1.5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButton<String?>(
                              value: _controller.selectedLevelFilter,
                              underline: const SizedBox.shrink(),
                              isDense: true,
                              icon: const Icon(Icons.expand_more, size: 16, color: AppColors.mutedForeground),
                              style: const TextStyle(fontSize: 13, color: AppColors.text, fontWeight: FontWeight.w600),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(l10n.allLevels),
                                ),
                                ...group.activeLevels.map((levelId) => DropdownMenuItem<String?>(
                                  value: levelId,
                                  child: Text(_localizedLevelName(levelId, l10n)),
                                )),
                              ],
                              onChanged: (val) => _controller.setLevelFilter(val),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Students grouped by Level
                  if (studentsByLevel.isEmpty)
                    EmptyState(icon: Icons.search_off, title: AppLocalizations.of(context)!.noStudentsInGroup, subtitle: AppLocalizations.of(context)!.addStudentsOrSearch)
                  else
                    ...studentsByLevel.entries.map((entry) {
                      final levelId = entry.key;
                      final students = entry.value;
                      final levelLabel = _localizedLevelName(levelId, l10n);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Level sub-header
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 8, bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    levelLabel,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.3),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(l10n.studentsCount(students.length.toString()), style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                              ],
                            ),
                          ),

                          // Student cards for this level
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return _buildUserCard(
                                user: student,
                                avatarColor: AppColors.primary.withValues(alpha: 0.1),
                                avatarTextColor: AppColors.primary,
                                onRemove: () => _controller.removeStudent(student.id),
                                isStudent: true,
                              );
                            },
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Reusable Widgets ──────────────────────────────

  Widget _buildSectionHeader(String title, {required VoidCallback onAdd}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 12),
      child: Row(
        children: [
          Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 0.6))),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 14),
            label: Text(AppLocalizations.of(context)!.addButton, style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard({
    required dynamic user,
    required Color avatarColor,
    required Color avatarTextColor,
    required VoidCallback onRemove,
    bool isStudent = false,
  }) {
    final name = user.name as String;
    final parts = name.split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (parts.isNotEmpty && parts[0].length >= 2 ? parts[0].substring(0, 2).toUpperCase() : '??');

    final UserModel? studentUser = isStudent ? (user as UserModel) : null;
    final bool online = studentUser?.isOnline ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: avatarColor,
                foregroundColor: avatarTextColor,
                radius: 20,
                child: Text(initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              if (isStudent)
                PositionedDirectional(end: 0, bottom: 0, child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: online ? AppColors.success : AppColors.mutedForeground,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                )),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(child: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text), overflow: TextOverflow.ellipsis)),
                  if (studentUser?.studentNumber != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                      child: Text(studentUser!.studentNumber!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ],
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  if (studentUser?.username != null)
                    Text('@${studentUser!.username}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  if (isStudent) ...[
                    const Text('  ·  ', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                    Icon(Icons.circle, size: 6, color: online ? AppColors.success : AppColors.mutedForeground),
                    const SizedBox(width: 3),
                    Text(_localizedLastActive(studentUser?.lastActive, AppLocalizations.of(context)!), style: TextStyle(fontSize: 11, color: online ? AppColors.success : AppColors.mutedForeground, fontWeight: online ? FontWeight.w600 : FontWeight.normal)),
                  ],
                  if (!isStudent)
                    Text(user.email as String, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                ]),
              ],
            ),
          ),
          if (isStudent)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18, color: AppColors.mutedForeground),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) {
                if (val == 'reset') _showResetPinDialog(studentUser!);
                if (val == 'remove') onRemove();
                if (val == 'delete') _showDeleteStudentConfirmation(studentUser!);
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'reset', child: Row(children: [Icon(Icons.lock_reset, size: 16, color: AppColors.primary), SizedBox(width: 8), Text(AppLocalizations.of(context)!.resetPin)])),
                PopupMenuItem(value: 'remove', child: Row(children: [Icon(Icons.remove_circle_outline, size: 16, color: AppColors.warning), SizedBox(width: 8), Text(AppLocalizations.of(context)!.removeFromGroup)])),
                PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 16, color: AppColors.error), SizedBox(width: 8), Text(AppLocalizations.of(context)!.deletePermanently, style: TextStyle(color: AppColors.error))])),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppColors.error),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }

  void _showDeleteStudentConfirmation(UserModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)!.deleteStudent, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(AppLocalizations.of(context)!.deleteStudentConfirm(student.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancelButton),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _controller.deleteStudent(student.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.studentDeleted(student.name)), behavior: SnackBarBehavior.floating),
              );
            },
            child: Text(AppLocalizations.of(context)!.deleteButton, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Private helper: Returns the human-readable display name for a level ID ──
String levelDisplayName(String levelId) =>
    GroupDetailController.levelMap[levelId] ?? levelId;

// ── Private data class: Holds form state for one student row in the create dialog ──
class _CreateStudentRow {
  final nameCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final pinCtrl = TextEditingController();
  String? nameError;
  String? usernameError;
  String? pinError;

  void dispose() {
    nameCtrl.dispose();
    usernameCtrl.dispose();
    pinCtrl.dispose();
  }
}

// ── Private Widget: Bulk-select student tile (checkbox + name only) ──

class _BulkSelectStudentTile extends StatelessWidget {
  final dynamic student;
  final bool isSelected;
  final VoidCallback onToggle;

  const _BulkSelectStudentTile({
    required this.student,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.07) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.35) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onToggle(),
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('@${student.username ?? student.userNumber}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

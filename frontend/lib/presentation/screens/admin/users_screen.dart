/// Presentation Tier — Screen
/// Path: lib/presentation/screens/admin/users_screen.dart
///
///  Zero business logic — tab, search, delegation all via UserController
///  Zero mock data — instructor/student lists from UserRepository via controller
///  Uses ListenableBuilder for reactivity
library;

import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../logic/controllers/user_controller.dart';
import '../../../di/service_locator.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UserController _controller = getIt<UserController>();

  Widget _buildUserRow(String name, String email, String staffNumber, String? phone, bool isInstructor, {String? delegationText, VoidCallback? onTap, VoidCallback? onEditProfile, VoidCallback? onDelete}) {
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('');
    final displayInitials = initials.length >= 2 ? initials.substring(0, 2).toUpperCase() : initials.toUpperCase();
    final bgColor = AppColors.accent.withValues(alpha: 0.2);
    final fgColor = const Color(0xFFa07800);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(displayInitials, style: TextStyle(fontWeight: FontWeight.bold, color: fgColor)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                  const SizedBox(height: 2),
                  Text(email, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  Text('SN: $staffNumber', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  if (phone != null && phone.isNotEmpty)
                    Text(phone, style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  if (delegationText != null && delegationText.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(delegationText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    AppLocalizations.of(context)!.roleInstructor,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fgColor),
                  ),
                ),
                if (onEditProfile != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.mutedForeground),
                    onPressed: onEditProfile,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
                if (onDelete != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddInstructorDialog() {
    String name = '';
    String email = '';
    String phoneNumber = '';
    String homeAddress = '';
    List<String> assignedLevels = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(AppLocalizations.of(context)!.addInstructorTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.fullNameLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) => name = val,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.emailAddressLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) => email = val,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.phoneNumberLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) => phoneNumber = val,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.homeAddressLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) => homeAddress = val,
                  ),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.assignLevels, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['l1', 'l2', 'l3'].map((level) {
                      final isSelected = assignedLevels.contains(level);
                      return ChoiceChip(
                        label: Text(AppLocalizations.of(context)!.levelLabel(level.substring(1))),
                        selected: isSelected,
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              assignedLevels.add(level);
                            } else {
                              assignedLevels.remove(level);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: AppColors.mutedForeground)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (name.isEmpty || email.isEmpty) return;
                    _controller.addInstructor(name, email, phoneNumber.isNotEmpty ? phoneNumber : null, homeAddress.isNotEmpty ? homeAddress : null, assignedLevels);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!.instructorAddedSuccess),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 4),
                    ));
                  },
                  child: Text(AppLocalizations.of(context)!.add, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showEditProfileDialog(dynamic instructor) {
    String name = instructor.name;
    String email = instructor.email ?? '';
    String phoneNumber = instructor.phoneNumber ?? '';
    String homeAddress = instructor.address ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppLocalizations.of(context)!.editProfileTitle(instructor.name), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: TextEditingController(text: name),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.fullNameLabel,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: email),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.emailAddressLabel,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => email = val,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: phoneNumber),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.phoneNumberLabel,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => phoneNumber = val,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: homeAddress),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.homeAddressLabel,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) => homeAddress = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: AppColors.mutedForeground)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                _controller.updateInstructorProfile(instructor.id, name, email, phoneNumber.isNotEmpty ? phoneNumber : null, homeAddress.isNotEmpty ? homeAddress : null);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.profileUpdated(instructor.name)),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                ));
              },
              child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditLevelsDialog(String instructorId, String instructorName, List<String> currentLevels) {
    List<String> selectedLevels = List<String>.from(currentLevels);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(AppLocalizations.of(context)!.editLevelsTitle(instructorName), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.selectLevelsSubtitle, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                  const SizedBox(height: 16),
                  ...['l1', 'l2', 'l3'].map((level) {
                    final isSelected = selectedLevels.contains(level);
                    final l10n = AppLocalizations.of(context)!;
                    final labelMap = {'l1': l10n.levelBeginner, 'l2': l10n.levelIntermediate, 'l3': l10n.levelAdvanced};
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(labelMap[level] ?? level, style: const TextStyle(fontSize: 14)),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) {
                            selectedLevels.add(level);
                          } else {
                            selectedLevels.remove(level);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: AppColors.mutedForeground)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    _controller.updateInstructorLevels(instructorId, selectedLevels);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!.levelsUpdated(instructorName)),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
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
        final instructors = _controller.instructors;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
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
                                Text(AppLocalizations.of(context)!.staffInstructorsTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(AppLocalizations.of(context)!.instructorsCount((instructors.length).toString()), style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddInstructorDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.text,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          shadowColor: AppColors.accent.withValues(alpha: 0.3),
                        ),
                        icon: const Icon(Icons.add, size: 15),
                        label: Text(AppLocalizations.of(context)!.addInstructorTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                            decoration: InputDecoration(hintText: AppLocalizations.of(context)!.searchByNameEmail,
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
                  child: Container(
                    margin: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: instructors.map((e) {
                        final levelLabels = e.assignedLevels.map((l) {
                          final num = l.replaceAll('l', '');
                          return AppLocalizations.of(context)!.levelLabel(num);
                        }).toList();
                        String assigned = levelLabels.isEmpty ? AppLocalizations.of(context)!.noLevelsAssigned : levelLabels.join(', ');
                        return _buildUserRow(
                                e.name,
                                e.email ?? '',
                                e.userNumber.toString(),
                                e.phoneNumber,
                                true,
                                delegationText: assigned,
                                onTap: () => _showEditLevelsDialog(e.id, e.name, e.assignedLevels),
                                onEditProfile: () => _showEditProfileDialog(e),
                                onDelete: () => _showDeleteConfirmation(e.id, e.name),
                              );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(String userId, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)!.deleteUserTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(AppLocalizations.of(context)!.deleteUserConfirmation(userName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _controller.deleteInstructor(userId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.userDeletedSuccess(userName)), behavior: SnackBarBehavior.floating),
              );
            },
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

/// Presentation Tier — Screen
/// Path: lib/presentation/screens/admin/users_screen.dart
///
///  Zero business logic — tab, search, delegation all via UserController
///  Zero mock data — instructor/student lists from UserRepository via controller
///  Uses ListenableBuilder for reactivity
library;

import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import '../../../data/models/user_model.dart';
import '../../../theme/app_theme.dart';
import '../../../logic/controllers/user_controller.dart';
import '../../../di/service_locator.dart';
import '../../../utils/level_helpers.dart';
import 'package:intl/intl.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with SingleTickerProviderStateMixin {
  final UserController _controller = getIt<UserController>();
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _archivedLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _searchController.clear();
      _controller.setSearch('');
      if (_tabController.index == 2 && !_archivedLoaded) {
        _archivedLoaded = true;
        _controller.getArchivedUsers();
      }
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Row builders ──────────────────────

  Widget _buildUserRow(
    String name,
    String email,
    String staffNumber,
    String? phone,
    bool isInstructor, {
    String? delegationText,
    VoidCallback? onTap,
    VoidCallback? onEditProfile,
    VoidCallback? onResendEmail,
    VoidCallback? onDelete,
  }) {
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    AppLocalizations.of(context)!.roleInstructor,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fgColor),
                  ),
                ),
                if (onResendEmail != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.email_outlined, size: 18, color: AppColors.primary),
                    onPressed: onResendEmail,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Resend Email',
                  ),
                ],
                if (onEditProfile != null) ...[
                  const SizedBox(width: 4),
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

  Widget _buildStudentRow(
    UserModel student, {
    required String levelText,
    VoidCallback? onArchive,
    VoidCallback? onResetPin,
  }) {
    final initials = student.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('');
    final displayInitials = initials.length >= 2 ? initials.substring(0, 2).toUpperCase() : initials.toUpperCase();
    const bgColor = Color(0xFF2563EB);
    const fgColor = Color(0xFF1D4ED8);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(displayInitials, style: const TextStyle(fontWeight: FontWeight.bold, color: fgColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 2),
                Text('@${student.username ?? '—'}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                Text('$levelText  •  ${student.studentNumber ?? '#${student.userNumber}'}', style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppLocalizations.of(context)!.studentRoleLabel,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fgColor),
                ),
              ),
              if (onResetPin != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.pin_outlined, size: 18, color: AppColors.mutedForeground),
                  onPressed: onResetPin,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: AppLocalizations.of(context)!.resetPin,
                ),
              ],
              if (onArchive != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.archive_outlined, size: 18, color: AppColors.error),
                  onPressed: onArchive,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedRow(UserModel user) {
    final isInstructor = user.role == UserRole.instructor;
    final initials = user.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join('');
    final displayInitials = initials.length >= 2 ? initials.substring(0, 2).toUpperCase() : initials.toUpperCase();

    return InkWell(
      onTap: () => _showArchivedUserDetails(user),
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
              decoration: BoxDecoration(
                color: AppColors.mutedForeground.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                displayInitials,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mutedForeground),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
                  const SizedBox(height: 2),
                  Text(
                    isInstructor ? (user.email ?? '') : '@${user.username ?? '—'}',
                    style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mutedForeground.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isInstructor
                        ? AppLocalizations.of(context)!.roleInstructor
                        : AppLocalizations.of(context)!.studentRoleLabel,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedForeground),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 16, color: AppColors.mutedForeground),
              ],
            ),
          ],
        ),
      ),
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
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.text)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showArchivedUserDetails(UserModel user) {
    final isInstructor = user.role == UserRole.instructor;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      builder: (ctx) {
        final archivedDateStr = user.createdAt != null
            ? 'Archived on: ${DateFormat('MMM d, y').format(user.createdAt!)}'
            : 'Archived on: —';
        final l10n = AppLocalizations.of(ctx)!;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.mutedForeground.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isInstructor ? l10n.roleInstructor : l10n.studentRoleLabel,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.mutedForeground),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isInstructor) ...[
                _detailRow(Icons.email_outlined, 'Email', user.email ?? '—'),
                _detailRow(Icons.phone_outlined, 'Phone', user.phoneNumber ?? '—'),
                _detailRow(Icons.home_outlined, 'Address', user.address ?? '—'),
                _detailRow(
                  Icons.layers_outlined,
                  'Assigned Levels',
                  user.assignedLevels.isEmpty
                      ? '—'
                      : user.assignedLevels.map(levelDisplayName).join(', '),
                ),
              ] else ...[
                _detailRow(Icons.alternate_email, 'Username', '@${user.username ?? '—'}'),
                _detailRow(Icons.layers_outlined, 'Level', levelDisplayName(user.levelId)),
                _detailRow(Icons.numbers, 'Student Number', user.studentNumber ?? '#${user.userNumber}'),
              ],
              _detailRow(Icons.archive_outlined, 'Archived', archivedDateStr),
              const SizedBox(height: 4),
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
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.mutedForeground)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _restoreUser(user.id, user.name);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Restore', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListContainer({
    required bool isEmpty,
    required String emptyText,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 20, end: 20, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(emptyText, style: const TextStyle(color: AppColors.mutedForeground)),
              ),
            )
          : ListView(
              padding: EdgeInsets.zero,
              children: children,
            ),
    );
  }

  // ── Dialogs ───────────────────────────

  static final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  void _showAddInstructorDialog() {
    String name = '';
    String email = '';
    String phoneNumber = '';
    String homeAddress = '';
    List<String> assignedLevels = [];
    String? emailError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isEmailValid = email.isNotEmpty && _emailRegex.hasMatch(email);

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
                    onChanged: (val) => setDialogState(() => name = val),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.emailAddressLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      errorText: emailError,
                      errorMaxLines: 2,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) => setDialogState(() {
                      email = val;
                      emailError = null;
                    }),
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
                  onPressed: name.isEmpty || !isEmailValid ? null : () async {
                    final exists = await _controller.emailExists(email);
                    if (exists) {
                      setDialogState(() => emailError = 'Email already registered');
                      return;
                    }
                    if (!context.mounted) return;
                    final successMsg = AppLocalizations.of(context)!.instructorAddedSuccess;
                    Navigator.pop(context);
                    try {
                      await _controller.addInstructor(name, email, phoneNumber.isNotEmpty ? phoneNumber : null, homeAddress.isNotEmpty ? homeAddress : null, assignedLevels);
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                          content: Text(successMsg),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 4),
                        ));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                          content: Text('Failed to add instructor: $e'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 6),
                        ));
                      }
                    }
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
                    final labelMap = {'l1': l10n.levelOneLabel, 'l2': l10n.levelTwoLabel, 'l3': l10n.levelThreeLabel};
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

  void _showDeleteConfirmation(String userId, String userName, {bool isStudent = false}) {
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
              if (isStudent) {
                _controller.deleteStudent(userId);
              } else {
                _controller.deleteInstructor(userId);
              }
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

  void _showResetPinDialog(String studentId, String studentName) {
    String newPin = '';
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(AppLocalizations.of(context)!.pinResetTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.newPinForStudent(studentName),
                    style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.pinLabel,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: (val) => setDialogState(() => newPin = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: AppColors.mutedForeground)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: newPin.length == 6 && RegExp(r'^\d{6}$').hasMatch(newPin)
                      ? () async {
                          final nav = Navigator.of(ctx);
                          nav.pop();
                          try {
                            await _controller.resetStudentPin(studentId, newPin);
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                                content: Text('PIN reset for $studentName'),
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
                                content: Text('Failed to reset PIN: $e'),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          }
                        }
                      : null,
                  child: Text(AppLocalizations.of(context)!.save, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _resendWelcomeEmail(String instructorId, String instructorName) async {
    try {
      await _controller.resendWelcomeEmail(instructorId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Welcome email resent to $instructorName'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to resend email: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<void> _restoreUser(String uid, String name) async {
    try {
      await _controller.restoreUser(uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('User restored successfully'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to restore: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  // ── Build ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final l10n = AppLocalizations.of(context)!;
        final tabIdx = _tabController.index;
        final instructors = _controller.instructors;
        final students = _controller.students;
        final archivedUsers = _controller.archivedUsers;

        final String headerTitle;
        final String headerCount;
        final Widget? headerAction;

        if (tabIdx == 0) {
          headerTitle = l10n.staffInstructorsTitle;
          headerCount = l10n.instructorsCount(instructors.length.toString());
          headerAction = ElevatedButton.icon(
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
            label: Text(l10n.addInstructorTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          );
        } else if (tabIdx == 1) {
          headerTitle = l10n.statStudents;
          headerCount = l10n.studentsCount(students.length.toString());
          headerAction = null;
        } else {
          headerTitle = 'Archived';
          headerCount = '${archivedUsers.length} Archived';
          headerAction = null;
        }

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
                                Text(headerTitle, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(headerCount, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                      if (headerAction case final action?) action,
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
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    tabs: [
                      Tab(text: l10n.statInstructors),
                      Tab(text: l10n.statStudents),
                      const Tab(text: 'Archived'),
                    ],
                  ),
                ),

                // Search bar (hidden on archived tab but maintains size)
                Visibility(
                  visible: tabIdx < 2,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Padding(
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
                              controller: _searchController,
                              onChanged: (val) => _controller.setSearch(val),
                              decoration: InputDecoration(
                                hintText: tabIdx == 0 ? l10n.searchByNameEmail : l10n.searchByNameUsername,
                                border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          if (_controller.search.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _controller.setSearch('');
                              },
                              child: const Icon(Icons.close, size: 15, color: AppColors.mutedForeground),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ── Instructors ──
                      _buildListContainer(
                        isEmpty: instructors.isEmpty,
                        emptyText: l10n.noInstructorsFound,
                        children: instructors.map((e) {
                          final levelLabels = e.assignedLevels.map((l) {
                            final num = l.replaceAll('l', '');
                            return l10n.levelLabel(num);
                          }).toList();
                          final assigned = levelLabels.isEmpty ? l10n.noLevelsAssigned : levelLabels.join(', ');
                          return _buildUserRow(
                            e.name,
                            e.email ?? '',
                            e.userNumber.toString(),
                            e.phoneNumber,
                            true,
                            delegationText: assigned,
                            onTap: () => _showEditLevelsDialog(e.id, e.name, e.assignedLevels),
                            onEditProfile: () => _showEditProfileDialog(e),
                            onResendEmail: () => _resendWelcomeEmail(e.id, e.name),
                            onDelete: () => _showDeleteConfirmation(e.id, e.name),
                          );
                        }).toList(),
                      ),

                      // ── Students ──
                      _buildListContainer(
                        isEmpty: students.isEmpty,
                        emptyText: l10n.noStudentsFound,
                        children: students.map((s) {
                          final levelText = s.levelId != null
                              ? l10n.levelLabel(s.levelId!.replaceAll('l', ''))
                              : '—';
                          return _buildStudentRow(
                            s,
                            levelText: levelText,
                            onArchive: () => _showDeleteConfirmation(s.id, s.name, isStudent: true),
                            onResetPin: () => _showResetPinDialog(s.id, s.name),
                          );
                        }).toList(),
                      ),

                      // ── Archived ──
                      _buildListContainer(
                        isEmpty: archivedUsers.isEmpty,
                        emptyText: 'No archived users',
                        children: archivedUsers.map((u) => _buildArchivedRow(u)).toList(),
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
}

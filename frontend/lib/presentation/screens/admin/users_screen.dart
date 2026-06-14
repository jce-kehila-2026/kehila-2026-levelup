/// Presentation Tier — Screen
/// Path: lib/presentation/screens/admin/users_screen.dart
///
///  Zero business logic — tab, search, delegation all via UserController
///  Zero mock data — instructor/student lists from UserRepository via controller
///  Uses ListenableBuilder for reactivity
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/l10n/app_localizations.dart';
import '../../../data/models/curriculum_model.dart';
import '../../../data/models/user_model.dart';
import '../../../theme/app_theme.dart';
import '../../../logic/controllers/user_controller.dart';
import '../../../di/service_locator.dart';
import 'package:intl/intl.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with SingleTickerProviderStateMixin {
  final UserController _controller = getIt<UserController>();
  late final TabController _tabController;
  bool _archivedLoaded = false;
  int _archiveCategory = 0; // 0=Instructors, 1=Students

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
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
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.mutedForeground),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onSelected: (value) {
                    if (value == 'resend' && onResendEmail != null) onResendEmail();
                    if (value == 'edit' && onEditProfile != null) onEditProfile();
                    if (value == 'delete' && onDelete != null) onDelete();
                  },
                  itemBuilder: (context) => [
                    if (onResendEmail != null)
                      const PopupMenuItem(
                        value: 'resend',
                        child: Row(
                          children: [
                            Icon(Icons.email_outlined, size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Resend Welcome Email', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    if (onEditProfile != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18, color: AppColors.mutedForeground),
                            SizedBox(width: 8),
                            Text('Edit Profile', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(fontSize: 13, color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                ),
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
                      : user.assignedLevels.map((id) =>
                          _controller.levels.firstWhere((l) => l.id == id, orElse: () => LevelModel(id: id, name: id)).name
                        ).join(', '),
                ),
              ] else ...[
                _detailRow(Icons.alternate_email, 'Username', '@${user.username ?? '—'}'),
                _detailRow(Icons.layers_outlined, 'Level',
                  _controller.levels.firstWhere((l) => l.id == user.levelId, orElse: () => LevelModel(id: user.levelId ?? '', name: user.levelId ?? '—')).name,
                ),
                _detailRow(Icons.numbers, 'Student Number', user.studentNumber ?? '#${user.userNumber}'),
              ],
              _detailRow(Icons.archive_outlined, 'Archived', archivedDateStr),
              const SizedBox(height: 4),
              // ── Restore / Close ──
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
              const SizedBox(height: 10),
              // ── Permanently Delete (danger zone) ──
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_forever, color: AppColors.error, size: 18),
                  label: const Text('Permanently Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _permanentlyDeleteUser(user.id, user.name);
                  },
                ),
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
    String? phoneError;

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
              content: SingleChildScrollView(
                child: Column(
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
                        errorText: phoneError,
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (val) => setDialogState(() {
                        phoneNumber = val;
                        phoneError = null;
                      }),
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
                      children: _controller.levels.map((level) {
                        final isSelected = assignedLevels.contains(level.id);
                        return ChoiceChip(
                          label: Text(level.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                assignedLevels.add(level.id);
                              } else {
                                assignedLevels.remove(level.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
                    final phoneVal = phoneNumber.trim();
                    if (phoneVal.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(phoneVal)) {
                      setDialogState(() => phoneError = 'Phone number must be exactly 10 digits');
                      return;
                    }
                    final exists = await _controller.emailExists(email);
                    if (exists) {
                      setDialogState(() => emailError = 'Email already registered');
                      return;
                    }
                    if (!context.mounted) return;
                    final successMsg = AppLocalizations.of(context)!.instructorAddedSuccess;
                    Navigator.pop(context);
                    try {
                      await _controller.addInstructor(name, email, phoneVal.isNotEmpty ? phoneVal : null, homeAddress.isNotEmpty ? homeAddress : null, assignedLevels);
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

  void _showAddStudentDialog() {
    // Each entry: {name, username, pin, nameError, usernameError}
    String genPin() =>
        (100000 + Random().nextInt(900000)).toString();

    final rows = <Map<String, dynamic>>[
      {
        'nameCtrl': TextEditingController(),
        'usernameCtrl': TextEditingController(),
        'pin': genPin(),
        'nameError': null,
        'usernameError': null,
      }
    ];

    String levelId =
        _controller.levels.isNotEmpty ? _controller.levels.first.id : '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              titlePadding:
                  const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding:
                  const EdgeInsets.fromLTRB(24, 16, 24, 0),
              title: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Add Students',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => setDialogState(() {
                      rows.add({
                        'nameCtrl': TextEditingController(),
                        'usernameCtrl': TextEditingController(),
                        'pin': genPin(),
                        'nameError': null,
                        'usernameError': null,
                      });
                    }),
                    icon: const Icon(Icons.add, size: 16,
                        color: AppColors.primary),
                    label: const Text('Add Row',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6)),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Student rows ──
                      ...List.generate(rows.length, (i) {
                        final row = rows[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              // Row header
                              Row(
                                children: [
                                  Text(
                                    'Student ${i + 1}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary),
                                  ),
                                  const Spacer(),
                                  if (rows.length > 1)
                                    InkWell(
                                      onTap: () => setDialogState(() {
                                        (row['nameCtrl']
                                                as TextEditingController)
                                            .dispose();
                                        (row['usernameCtrl']
                                                as TextEditingController)
                                            .dispose();
                                        rows.removeAt(i);
                                      }),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                      child: const Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color:
                                                AppColors.error),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Full Name
                              TextField(
                                controller: row['nameCtrl']
                                    as TextEditingController,
                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!
                                          .fullNameLabel,
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12),
                                  errorText:
                                      row['nameError'] as String?,
                                  isDense: true,
                                ),
                                onChanged: (_) => setDialogState(
                                    () => row['nameError'] = null),
                              ),
                              const SizedBox(height: 10),
                              // Username
                              TextField(
                                controller: row['usernameCtrl']
                                    as TextEditingController,
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  hintText: 'ali.hassan',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  contentPadding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12),
                                  errorText: row['usernameError']
                                      as String?,
                                  errorMaxLines: 2,
                                  isDense: true,
                                ),
                                onChanged: (_) => setDialogState(() =>
                                    row['usernameError'] = null),
                              ),
                              const SizedBox(height: 10),
                              // Read-only PIN bar
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 11),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius:
                                      BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lock_outline,
                                        size: 16,
                                        color:
                                            AppColors.mutedForeground),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'PIN: ${row['pin']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 2,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ),
                                    // Regenerate PIN button
                                    Tooltip(
                                      message: 'Regenerate PIN',
                                      child: InkWell(
                                        onTap: () => setDialogState(
                                            () => row['pin'] =
                                                genPin()),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        child: const Padding(
                                          padding: EdgeInsets.all(4),
                                          child: Icon(
                                              Icons.refresh,
                                              size: 16,
                                              color: AppColors
                                                  .mutedForeground),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      // ── Level selector ──
                      if (_controller.levels.isNotEmpty) ...[
                        const Text('Level',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                                fontSize: 13)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _controller.levels.map((level) {
                            final isSel = levelId == level.id;
                            return ChoiceChip(
                              label: Text(level.name),
                              selected: isSel,
                              onSelected: (sel) {
                                if (sel) {
                                  setDialogState(
                                      () => levelId = level.id);
                                }
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    for (final r in rows) {
                      (r['nameCtrl'] as TextEditingController)
                          .dispose();
                      (r['usernameCtrl'] as TextEditingController)
                          .dispose();
                    }
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.cancel,
                      style: const TextStyle(
                          color: AppColors.mutedForeground)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    // Validate all rows
                    bool hasError = false;
                    setDialogState(() {
                      for (final r in rows) {
                        final name = (r['nameCtrl']
                                as TextEditingController)
                            .text
                            .trim();
                        final uname = (r['usernameCtrl']
                                as TextEditingController)
                            .text
                            .trim();

                        if (name.isEmpty) {
                          r['nameError'] = 'Required';
                          hasError = true;
                        }
                        if (uname.isEmpty) {
                          r['usernameError'] = 'Required';
                          hasError = true;
                        } else if (uname.contains(' ') ||
                            uname != uname.toLowerCase()) {
                          r['usernameError'] =
                              'Lowercase, no spaces';
                          hasError = true;
                        }
                      }
                    });

                    if (hasError) return;

                    // Check for duplicate usernames within the batch
                    final usernames = rows
                        .map((r) => (r['usernameCtrl']
                                as TextEditingController)
                            .text
                            .trim()
                            .toLowerCase())
                        .toList();
                    final dupes = usernames
                        .toSet()
                        .length != usernames.length;
                    if (dupes) {
                      setDialogState(() {
                        for (int i = 0; i < rows.length; i++) {
                          final u = usernames[i];
                          if (usernames.indexOf(u) != i) {
                            rows[i]['usernameError'] =
                                'Duplicate username in batch';
                          }
                        }
                      });
                      return;
                    }

                    // Check each username against Firestore
                    for (int i = 0; i < rows.length; i++) {
                      final exists = await _controller
                          .usernameExists(usernames[i]);
                      if (exists) {
                        setDialogState(() => rows[i]
                            ['usernameError'] =
                            'Username already taken');
                        return;
                      }
                    }

                    if (!context.mounted) return;

                    // Build payload
                    final payload = rows
                        .map((r) => {
                              'name': (r['nameCtrl']
                                      as TextEditingController)
                                  .text
                                  .trim(),
                              'username': (r['usernameCtrl']
                                      as TextEditingController)
                                  .text
                                  .trim()
                                  .toLowerCase(),
                              'pin': r['pin'] as String,
                              'levelId': levelId,
                            })
                        .toList();

                    // Dispose controllers before closing dialog
                    for (final r in rows) {
                      (r['nameCtrl'] as TextEditingController)
                          .dispose();
                      (r['usernameCtrl'] as TextEditingController)
                          .dispose();
                    }

                    Navigator.pop(context);

                    // Show progress spinner
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(
                          child: CircularProgressIndicator()),
                    );

                    try {
                      final created = await _controller
                          .bulkAddStudents(payload);
                      if (!context.mounted) return;
                      Navigator.pop(context); // dismiss spinner
                      _showCredentialsDialog(created);
                    } catch (e) {
                      if (!context.mounted) return;
                      Navigator.pop(context); // dismiss spinner
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Failed to add students: $e'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 6),
                        ),
                      );
                    }
                  },
                  child: Text(
                    rows.length == 1 ? 'Add Student' : 'Add ${rows.length} Students',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCredentialsDialog(List<UserModel> users) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  users.length == 1 ? 'Student Created!' : 'Students Created!',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Important: Save the PIN below. For security reasons, it will not be shown again.',
                  style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: users.length,
                    separatorBuilder: (_, index) => const Divider(height: 20),
                    itemBuilder: (context, idx) {
                      final u = users[idx];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Username: ${u.username}',
                            style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PIN: ${u.pinCode}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                    letterSpacing: 2,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 16),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: u.pinCode ?? ''));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('PIN copied to clipboard'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('I have saved the PIN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(dynamic instructor) {
    final nameCtrl = TextEditingController(text: instructor.name);
    final emailCtrl = TextEditingController(text: instructor.email ?? '');
    final phoneCtrl = TextEditingController(text: instructor.phoneNumber ?? '');
    final addressCtrl = TextEditingController(text: instructor.address ?? '');
    String? phoneError;
    String? emailError;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(AppLocalizations.of(ctx)!.editProfileTitle(instructor.name), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(ctx)!.fullNameLabel,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailCtrl,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(ctx)!.emailAddressLabel,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        errorText: emailError,
                      ),
                      onChanged: (_) => setDialogState(() => emailError = null),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneCtrl,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(ctx)!.phoneNumberLabel,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        errorText: phoneError,
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setDialogState(() => phoneError = null),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressCtrl,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(ctx)!.homeAddressLabel,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(ctx)!.cancel, style: const TextStyle(color: AppColors.mutedForeground)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    final newName = nameCtrl.text.trim();
                    final newEmail = emailCtrl.text.trim();
                    final newPhone = phoneCtrl.text.trim();
                    final newAddress = addressCtrl.text.trim();

                    if (newName.isEmpty) return;
                    if (newEmail.isEmpty || !_emailRegex.hasMatch(newEmail)) {
                      setDialogState(() => emailError = 'Please enter a valid email address');
                      return;
                    }
                    if (newPhone.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(newPhone)) {
                      setDialogState(() => phoneError = 'Phone number must be exactly 10 digits');
                      return;
                    }

                    final scaffoldContext = context;
                    final nav = Navigator.of(ctx);

                    try {
                      await _controller.updateInstructorProfile(
                        instructor.id,
                        newName,
                        newEmail,
                        newPhone.isNotEmpty ? newPhone : null,
                        newAddress.isNotEmpty ? newAddress : null,
                      );
                      nav.pop();
                      if (scaffoldContext.mounted) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(SnackBar(
                          content: Text(AppLocalizations.of(scaffoldContext)!.profileUpdated(newName)),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    } catch (e) {
                      if (scaffoldContext.mounted) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(SnackBar(
                          content: Text('Failed to update profile: $e'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    }
                  },
                  child: Text(AppLocalizations.of(ctx)!.save, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameCtrl.dispose();
      emailCtrl.dispose();
      phoneCtrl.dispose();
      addressCtrl.dispose();
    });
  }

  void _showEditLevelsDialog(String instructorId, String instructorName, List<String> currentLevels) {
    List<String> selectedLevels = List<String>.from(currentLevels);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(AppLocalizations.of(ctx)!.editLevelsTitle(instructorName), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(ctx)!.selectLevelsSubtitle, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                  const SizedBox(height: 16),
                  ..._controller.levels.map((level) {
                    final isSelected = selectedLevels.contains(level.id);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(level.name, style: const TextStyle(fontSize: 14)),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) {
                            selectedLevels.add(level.id);
                          } else {
                            selectedLevels.remove(level.id);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(ctx)!.cancel, style: const TextStyle(color: AppColors.mutedForeground)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    _controller.updateInstructorLevels(instructorId, selectedLevels);
                    final scaffoldContext = context;
                    Navigator.pop(ctx);
                    if (scaffoldContext.mounted) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(scaffoldContext)!.levelsUpdated(instructorName)),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  child: Text(AppLocalizations.of(ctx)!.save, style: const TextStyle(fontWeight: FontWeight.bold)),
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
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Reset PIN?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
          content: Text('Are you sure you want to reset the PIN for $studentName? This will generate a new 6-digit random PIN.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.cancel, style: const TextStyle(color: AppColors.mutedForeground)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(ctx); // Dismiss confirmation dialog
                
                // Show loading spinner
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  final newPin = await _controller.resetStudentPin(studentId);
                  if (!mounted) return;
                  Navigator.pop(context); // Dismiss loading spinner

                  // Show new PIN dialog
                  showDialog(
                    context: context,
                    builder: (ctx2) => AlertDialog(
                      backgroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.all(28),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), shape: BoxShape.circle),
                            child: const Icon(Icons.lock_reset, size: 28, color: AppColors.accentDark),
                          ),
                          const SizedBox(height: 14),
                          const Text('PIN Reset Successful', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('New PIN for $studentName:', style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              newPin,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                                letterSpacing: 6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx2),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context); // Dismiss loading spinner
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to reset PIN: $e'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
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

  Future<void> _permanentlyDeleteUser(String uid, String name) async {
    try {
      await _controller.permanentlyDeleteUser(uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('"$name" permanently deleted'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete permanently: $e'),
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
        final archivedInstructors = archivedUsers.where((u) => u.role == UserRole.instructor).toList();
        final archivedStudents = archivedUsers.where((u) => u.role == UserRole.student).toList();

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
          headerAction = ElevatedButton.icon(
            onPressed: _showAddStudentDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.text,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              shadowColor: AppColors.accent.withValues(alpha: 0.3),
            ),
            icon: const Icon(Icons.add, size: 15),
            label: const Text('Add Student', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          );
        } else {
          headerTitle = 'Archive';
          headerCount = '${archivedUsers.length} archived';
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
                      ?headerAction,
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
                            final level = _controller.levels.firstWhere(
                              (lvl) => lvl.id == l,
                              orElse: () => LevelModel(id: l, name: ''),
                            );
                            if (level.name.isNotEmpty) {
                              return level.name;
                            }
                            final num = l.replaceAll('l', '');
                            return l10n.levelLabel(num);
                          }).toList();
                          levelLabels.sort(); // Sort levels alphabetically by name
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

                      // ── Archived (Instructors & Students) ──
                      Column(
                        children: [
                          // Sub-category selector
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                            child: Row(
                              children: [
                                _archiveCategoryChip('Instructors', 0, archivedInstructors.length),
                                const SizedBox(width: 8),
                                _archiveCategoryChip('Students', 1, archivedStudents.length),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: () {
                              final items = _archiveCategory == 0
                                  ? archivedInstructors
                                  : archivedStudents;
                              return _buildListContainer(
                                isEmpty: items.isEmpty,
                                emptyText: 'Nothing archived here',
                                children: items.map((u) => _buildArchivedRow(u)).toList(),
                              );
                            }(),
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

  Widget _archiveCategoryChip(String label, int index, int count) {
    final isSelected = _archiveCategory == index;
    return GestureDetector(
      onTap: () => setState(() => _archiveCategory = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}

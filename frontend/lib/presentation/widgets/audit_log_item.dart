import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../theme/app_theme.dart';
import '../../data/models/audit_log_model.dart';
import 'package:frontend/l10n/app_localizations.dart';

class AuditLogItem extends StatelessWidget {
  final AuditLog log;

  const AuditLogItem({super.key, required this.log});

  /// Format as "12 May 2026, 14:30" (locale-aware month abbreviation).
  String _formatExactTime(DateTime ts, String localeCode) {
    return intl.DateFormat('dd MMM yyyy, HH:mm', localeCode).format(ts);
  }

  /// Relative time label — fully localized.
  String _formatRelativeTime(DateTime ts, AppLocalizations l10n) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes.toString());
    if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours.toString());
    if (diff.inDays < 7) return l10n.timeAgoDays(diff.inDays.toString());
    return l10n.timeAgoWeeks((diff.inDays ~/ 7).toString());
  }

  /// Map Firestore action strings to localized display text.
  String _localizeAction(AppLocalizations l10n) {
    final a = log.action.toLowerCase();
    if (a.contains('created') && a.contains('level')) return l10n.actionCreatedLevel;
    if (a.contains('added') && a.contains('instructor')) return l10n.actionAddedInstructor;
    if (a.contains('created assignment') || a.contains('assigned from')) return l10n.actionCreatedAssignment;
    if (a.contains('revised')) return l10n.actionRevisedGrade;
    if (a.contains('graded') || a.contains('grade')) return l10n.actionGradedSubmission;
    if (a.contains('submitted')) return l10n.actionSubmittedAssignment;
    if (a.contains('added') && a.contains('student')) return l10n.actionAddedStudent;
    if (a.contains('reset') && a.contains('pin')) return l10n.actionResetPin;
    if (a.contains('joined group')) return l10n.actionJoinedGroup;
    return log.action;
  }

  /// Choose icon and color based on action content.
  ({IconData icon, Color color}) _getActionStyle() {
    final a = log.action.toLowerCase();
    if (a.contains('graded') || a.contains('grade')) {
      return (icon: Icons.check_circle_outline, color: const Color(0xFF22C55E));
    }
    if (a.contains('revised') || a.contains('revise')) {
      return (icon: Icons.rate_review_outlined, color: const Color(0xFFF59E0B));
    }
    if (a.contains('created assignment') || a.contains('assigned from')) {
      return (icon: Icons.assignment_outlined, color: const Color(0xFF3B82F6));
    }
    if (a.contains('added new student') || a.contains('added student')) {
      return (icon: Icons.person_add_outlined, color: const Color(0xFF8B5CF6));
    }
    if (a.contains('removed student')) {
      return (icon: Icons.person_remove_outlined, color: const Color(0xFFEF4444));
    }
    if (a.contains('reset') && a.contains('pin')) {
      return (icon: Icons.lock_reset, color: const Color(0xFFEC4899));
    }
    if (a.contains('submitted') || a.contains('submission')) {
      return (icon: Icons.file_upload_outlined, color: const Color(0xFF06B6D4));
    }
    if (a.contains('level') || a.contains('curriculum') || a.contains('content')) {
      return (icon: Icons.menu_book_outlined, color: const Color(0xFF6366F1));
    }
    if (a.contains('schedule') || a.contains('updated group')) {
      return (icon: Icons.calendar_month_outlined, color: const Color(0xFF14B8A6));
    }
    if (a.contains('joined group')) {
      return (icon: Icons.group_add_outlined, color: const Color(0xFF0EA5E9));
    }
    if (a.contains('deleted')) {
      return (icon: Icons.delete_outline, color: const Color(0xFFEF4444));
    }
    // Fallback
    switch (log.performerRole) {
      case 'admin':
        return (icon: Icons.shield, color: const Color(0xFF8B5CF6));
      case 'instructor':
        return (icon: Icons.school, color: const Color(0xFFF59E0B));
      case 'student':
      default:
        return (icon: Icons.person, color: AppColors.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode;
    final style = _getActionStyle();
    final hasTarget = log.targetPersonName != null && log.targetPersonName!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Styled Circle Avatar ──
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: style.color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Icon(style.icon, size: 18, color: style.color),
          ),
          const SizedBox(width: 14),

          // ── Content ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action title
                Text(
                  _localizeAction(l10n),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                    height: 1.3,
                  ),
                ),

                // Details (the rich description)
                if (log.details != null && log.details!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    log.details!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.mutedForeground,
                      height: 1.35,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Target person row (if applicable)
                if (hasTarget) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.person, size: 12, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        log.targetPersonName!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (log.targetStudentNumber != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log.targetStudentNumber!,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 6),
                ],

                // Performer + Exact Date/Time — split into two rows to prevent truncation
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.performerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 10, color: AppColors.mutedForeground),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            _formatExactTime(log.preciseTimestamp, localeCode),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Relative time badge ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _formatRelativeTime(log.preciseTimestamp, l10n),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Presentation Tier — Screen
/// Path: lib/presentation/screens/details/assignment_detail_screen.dart
///
/// ✅ Shows assignment instructions with badges
/// ✅ Student answer area (student role only)
/// ✅ Submissions list with grading cards (instructor role)
/// ✅ Grade / Revise Grade bottom sheet
library;

import 'package:flutter/material.dart';
import '../../../services/pdf_export_service.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/badge.dart';
import '../../widgets/vibe_premium_renderer.dart';
import '../../../data/models/submission_model.dart';
import '../../../data/models/assignment_model.dart';
import '../../../logic/controllers/assignment_detail_controller.dart';
import '../../../di/service_locator.dart';
import 'package:frontend/l10n/app_localizations.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final String id;
  final bool isAdminView;
  const AssignmentDetailScreen({super.key, required this.id, this.isAdminView = false});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  late final AssignmentDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = getIt<AssignmentDetailController>(param1: widget.id);
  }

  // ── Grading Bottom Sheet ───────────────────────
  void _showGradeSheet(SubmissionModel submission) {
    final feedbackCtrl = TextEditingController(text: submission.feedback ?? '');
    GradeStatus selectedStatus = submission.status == GradeStatus.pending
        ? GradeStatus.correct
        : submission.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => StatefulBuilder(
          builder: (context, setSheetState) {
            final l10n = AppLocalizations.of(context)!;
            return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              // Title
              Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.grading, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(submission.status == GradeStatus.pending ? l10n.gradeSubmission : l10n.reviseGrade, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                  Text(_controller.studentName(submission.studentId), style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                ])),
              ]),
              const SizedBox(height: 20),

              // Status selector
              Align(alignment: AlignmentDirectional.centerStart, child: Text(l10n.statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 1))),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _buildStatusOption(l10n.statusCorrect, GradeStatus.correct, selectedStatus, AppColors.success, setSheetState, (v) => selectedStatus = v)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatusOption(l10n.statusIncorrect, GradeStatus.incorrect, selectedStatus, AppColors.error, setSheetState, (v) => selectedStatus = v)),
              ]),
              const SizedBox(height: 16),

              // Feedback
              Align(alignment: AlignmentDirectional.centerStart, child: Text(AppLocalizations.of(context)!.feedbackLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 1))),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.input, width: 1.5)),
                child: TextField(
                  controller: feedbackCtrl,
                  maxLines: 4, minLines: 3,
                  decoration: InputDecoration(hintText: AppLocalizations.of(context)!.writeFeedbackHint, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none, filled: false, contentPadding: EdgeInsets.all(14)),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 20),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _controller.gradeSubmission(submission.id, selectedStatus, feedbackCtrl.text.trim().isEmpty ? null : feedbackCtrl.text.trim());
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.gradeSaved), behavior: SnackBarBehavior.floating));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 4, shadowColor: AppColors.primary.withValues(alpha: 0.3)),
                  child: Text(AppLocalizations.of(context)!.saveGrade, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ]),
          ),
        );
        },
      ),
    ),
    );
  }

  Widget _buildStatusOption(String label, GradeStatus status, GradeStatus current, Color color, void Function(void Function()) setSheetState, void Function(GradeStatus) onChanged) {
    final selected = current == status;
    return GestureDetector(
      onTap: () => setSheetState(() => onChanged(status)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : AppColors.border, width: selected ? 2 : 1),
        ),
        alignment: Alignment.center,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(selected ? Icons.check_circle : Icons.circle_outlined, size: 16, color: selected ? color : AppColors.mutedForeground),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? color : AppColors.mutedForeground)),
        ]),
      ),
    );
  }

  // ── Build ──────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final assignment = _controller.assignment;
        final submissions = _controller.submissions;

        // ── Admin read-only view (separate rendering path) ──
        if (widget.isAdminView) {
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
              title: Text(
                AppLocalizations.of(context)!.assignmentDetails,
                style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text, height: 1.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.instructionsLabel,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    VibePremiumRenderer(
                      content: assignment.textContent ?? 'No instructions provided.',
                    ),
                  ],
                ),
              ),
            ),
          );
        }

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
            title: Text(AppLocalizations.of(context)!.assignmentDetails, style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              if (assignment.textContent != null && assignment.textContent!.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
                  tooltip: AppLocalizations.of(context)!.viewAsPdfTooltip,
                  onPressed: () => PdfExportService.exportAndShowPdf(
                    context,
                    assignment.title,
                    assignment.textContent!,
                  ),
                ),
              if (widget.isAdminView)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(AppLocalizations.of(context)!.editContent,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Content Area
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!widget.isAdminView) ...[
                          Wrap(spacing: 8, runSpacing: 6, children: [
                            BadgeWidget(label: assignment.isActive ? AppLocalizations.of(context)!.statusActive : AppLocalizations.of(context)!.statusInactive, variant: assignment.isActive ? BadgeVariant.success : BadgeVariant.muted),
                            BadgeWidget(label: assignment.deadlineText, variant: assignment.isOverdue ? BadgeVariant.error : BadgeVariant.warning),
                            BadgeWidget(label: assignment.groupName ?? AppLocalizations.of(context)!.noGroupAssigned, variant: BadgeVariant.defaultVariant),
                            if (_controller.levelName.isNotEmpty)
                              BadgeWidget(label: _controller.levelName, variant: BadgeVariant.info),
                          ]),
                          const SizedBox(height: 16),
                        ],
                        Text(assignment.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text, height: 1.3)),
                        const SizedBox(height: 24),
                        Text(AppLocalizations.of(context)!.instructionsLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        VibePremiumRenderer(
                          content: assignment.textContent ?? 'No instructions provided.',
                        ),
                        if (assignment.assignmentType == AssignmentType.multipleChoice && assignment.choices != null) ...[
                          const SizedBox(height: 24),
                          Text(AppLocalizations.of(context)!.optionsLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 1.2)),
                          const SizedBox(height: 12),
                          ...assignment.choices!.asMap().entries.map((e) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
                            child: Row(children: [
                              Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                                alignment: Alignment.center,
                                child: Text(String.fromCharCode(65 + e.key), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(e.value, style: const TextStyle(fontSize: 14, color: AppColors.text))),
                            ]),
                          )),
                        ],
                      ],
                    ),
                  ),

                  // ── Submissions Section (hidden for admins) ──
                  if (!widget.isAdminView) ...[
                    if (submissions.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Row(children: [
                          Container(width: 3, height: 18, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.submissionsLabel, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primaryDark, letterSpacing: 1.2)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: Text('${submissions.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ),
                        ]),
                      ),
                      ...submissions.map((sub) => _buildSubmissionCard(sub)),
                    ],
                    if (submissions.isEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                        child: Column(children: [
                          Icon(Icons.inbox_outlined, size: 40, color: AppColors.mutedForeground),
                          SizedBox(height: 8),
                          Text(AppLocalizations.of(context)!.noSubmissionsYet, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
                          SizedBox(height: 4),
                          Text(AppLocalizations.of(context)!.noStudentSubmissions, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                        ]),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Submission Card ────────────────────────────
  Widget _buildSubmissionCard(SubmissionModel sub) {
    // Status badge styling
    Color statusColor;
    Color statusBg;
    String statusLabel;
    IconData statusIcon;
    final l10n = AppLocalizations.of(context)!;
    switch (sub.status) {
      case GradeStatus.correct:
        statusColor = AppColors.success;
        statusBg = const Color(0xFFecfdf5);
        statusLabel = l10n.statusCorrect;
        statusIcon = Icons.check_circle;
        break;
      case GradeStatus.incorrect:
        statusColor = AppColors.error;
        statusBg = const Color(0xFFfef2f2);
        statusLabel = l10n.statusIncorrect;
        statusIcon = Icons.cancel;
        break;
      case GradeStatus.pending:
        statusColor = const Color(0xFF9ca3af);
        statusBg = const Color(0xFFf3f4f6);
        statusLabel = l10n.statusPending;
        statusIcon = Icons.hourglass_empty;
        break;
    }

    final studentName = _controller.studentName(sub.studentId);
    final submittedAgo = _formatTimeAgo(sub.submittedAt, l10n);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header: Student name + status badge
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Avatar
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.accent.withValues(alpha: 0.15)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(studentName.isNotEmpty ? studentName[0].toUpperCase() : '?', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(studentName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
            const SizedBox(height: 2),
            Text(l10n.submittedTimeAgo(submittedAgo), style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
          ])),
          // Status badge (top-right)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(statusIcon, size: 13, color: statusColor),
              const SizedBox(width: 4),
              Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),

        // Student's answer
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (sub.selectedChoice != null) ...[
              Text(AppLocalizations.of(context)!.selectedChoice, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
              const SizedBox(height: 4),
              Text(sub.selectedChoice!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
              if (sub.answer.isNotEmpty) const SizedBox(height: 8),
            ],
            if (sub.answer.isNotEmpty)
              Text(sub.answer, style: const TextStyle(fontSize: 13, color: AppColors.text, height: 1.5)),
          ]),
        ),

        // Instructor feedback (if graded)
        if (sub.feedback != null && sub.feedback!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.feedback, size: 14, color: AppColors.primary.withValues(alpha: 0.7)),
                const SizedBox(width: 6),
                Text(AppLocalizations.of(context)!.instructorFeedback, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary.withValues(alpha: 0.7), letterSpacing: 0.5)),
              ]),
              const SizedBox(height: 6),
              Text(sub.feedback!, style: const TextStyle(fontSize: 13, color: AppColors.text, height: 1.4)),
            ]),
          ),
        ],

        const SizedBox(height: 12),

        // Grade / Revise Grade button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showGradeSheet(sub),
            style: OutlinedButton.styleFrom(
              foregroundColor: sub.status == GradeStatus.pending ? AppColors.primary : AppColors.primaryDark,
              side: BorderSide(color: sub.status == GradeStatus.pending ? AppColors.primary : AppColors.primaryDark),
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.edit, size: 16),
            label: Text(
              sub.status == GradeStatus.pending ? AppLocalizations.of(context)!.gradeButton : AppLocalizations.of(context)!.reviseGrade,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ]),
    );
  }

  String _formatTimeAgo(DateTime date, AppLocalizations l10n) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return l10n.timeAgoMinutes(diff.inMinutes.toString());
    if (diff.inHours < 24) return l10n.timeAgoHours(diff.inHours.toString());
    return l10n.timeAgoDays(diff.inDays.toString());
  }
}

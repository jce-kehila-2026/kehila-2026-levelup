import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../data/models/audit_log_model.dart';
import 'audit_log_style.dart';
import 'golden_icon.dart';

/// Horizontal "recent activity" timeline for wide admin-dashboard layouts.
/// Reuses [AuditLogStyle] so the icon/label/type/time logic stays identical
/// to the vertical [AuditLogItem] list used on narrow screens.
class RecentActivityTimeline extends StatelessWidget {
  final List<AuditLog> logs;

  const RecentActivityTimeline({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < logs.length; i++)
            _buildEntry(l10n, logs[i], i, isLast: i == logs.length - 1),
        ],
      ),
    );
  }

  Widget _buildEntry(AppLocalizations l10n, AuditLog log, int index, {required bool isLast}) {
    final style = AuditLogStyle.actionStyle(log);
    final type = AuditLogStyle.typeInfo(log, l10n);
    final dotColor = index.isEven ? AppColors.primary : AppColors.accent;

    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connector dot + line
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              if (!isLast)
                Expanded(child: Container(height: 2, color: AppColors.border)),
              if (!isLast) const SizedBox(width: 4),
            ],
          ),
          const SizedBox(height: 12),
          GoldenIcon(icon: style.icon, size: 36, iconSize: 16, radius: 10),
          const SizedBox(height: 10),
          Text(
            AuditLogStyle.localizeAction(log, l10n),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text, height: 1.3),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              type.label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: type.color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AuditLogStyle.formatRelativeTime(log.preciseTimestamp, l10n),
            style: const TextStyle(fontSize: 11, color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }
}

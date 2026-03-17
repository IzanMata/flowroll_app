import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/models/tatami.dart';
import '../../shared/models/attendance.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  factory StatusBadge.matchupStatus(MatchupStatusEnum status) {
    return StatusBadge(
      label: switch (status) {
        MatchupStatusEnum.pending => 'Pending',
        MatchupStatusEnum.inProgress => 'In Progress',
        MatchupStatusEnum.completed => 'Completed',
        MatchupStatusEnum.cancelled => 'Cancelled',
      },
      color: switch (status) {
        MatchupStatusEnum.pending => AppColors.warning,
        MatchupStatusEnum.inProgress => AppColors.tertiary,
        MatchupStatusEnum.completed => AppColors.success,
        MatchupStatusEnum.cancelled => AppColors.muted,
      },
    );
  }

  factory StatusBadge.dropInStatus(DropInVisitorStatusEnum status) {
    return StatusBadge(
      label: switch (status) {
        DropInVisitorStatusEnum.pending => 'Pending',
        DropInVisitorStatusEnum.active => 'Active',
        DropInVisitorStatusEnum.expired => 'Expired',
      },
      color: switch (status) {
        DropInVisitorStatusEnum.pending => AppColors.warning,
        DropInVisitorStatusEnum.active => AppColors.success,
        DropInVisitorStatusEnum.expired => AppColors.muted,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall(color: color),
      ),
    );
  }
}

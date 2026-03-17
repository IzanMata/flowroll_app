import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/models/athlete.dart';

class BeltBadge extends StatelessWidget {
  const BeltBadge({
    super.key,
    required this.belt,
    this.stripes = 0,
    this.size = BeltBadgeSize.medium,
    this.showLabel = true,
  });

  final BeltEnum belt;
  final int stripes;
  final BeltBadgeSize size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final beltColor = AppColors.beltColor(belt.value);
    final isWhite = belt == BeltEnum.white;
    final height = switch (size) {
      BeltBadgeSize.small => 8.0,
      BeltBadgeSize.medium => 12.0,
      BeltBadgeSize.large => 16.0,
    };
    final width = switch (size) {
      BeltBadgeSize.small => 60.0,
      BeltBadgeSize.medium => 80.0,
      BeltBadgeSize.large => 120.0,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              belt.name[0].toUpperCase() + belt.name.substring(1),
              style: AppTextStyles.labelMedium(color: AppColors.muted),
            ),
          ),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: beltColor,
            borderRadius: BorderRadius.circular(height / 2),
            border: isWhite
                ? Border.all(color: AppColors.surfaceBorder, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: beltColor.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: stripes > 0
              ? _StripesOverlay(stripes: stripes, height: height)
              : null,
        ),
      ],
    );
  }
}

class _StripesOverlay extends StatelessWidget {
  const _StripesOverlay({required this.stripes, required this.height});

  final int stripes;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (int i = 0; i < stripes.clamp(0, 4); i++)
          Container(
            width: height * 0.6,
            height: height,
            margin: EdgeInsets.only(right: height * 0.2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

class BeltChip extends StatelessWidget {
  const BeltChip({
    super.key,
    required this.belt,
    this.selected = false,
    this.onTap,
  });

  final BeltEnum belt;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final beltColor = AppColors.beltColor(belt.value);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? beltColor.withValues(alpha: 0.2) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? beltColor : AppColors.surfaceBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: beltColor,
                shape: BoxShape.circle,
                boxShadow: selected
                    ? [BoxShadow(color: beltColor.withValues(alpha: 0.5), blurRadius: 4)]
                    : null,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              belt.name[0].toUpperCase() + belt.name.substring(1),
              style: AppTextStyles.labelMedium(
                color: selected ? AppColors.onSurface : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum BeltBadgeSize { small, medium, large }

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Enum-driven typed text widget that enforces the design-system type scale.
///
/// Usage:
/// ```dart
/// AppText('Hello', variant: AppTextVariant.titleMedium)
/// AppText('Sub-label', variant: AppTextVariant.bodySmall, color: AppColors.muted)
/// ```
enum AppTextVariant {
  displayLarge,
  displayMedium,
  displaySmall,
  headline,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
  button,
}

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.variant = AppTextVariant.bodyMedium,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  final String text;
  final AppTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  TextStyle _style(Color? c) => switch (variant) {
        AppTextVariant.displayLarge => AppTextStyles.displayLarge(color: c ?? AppColors.onBackground),
        AppTextVariant.displayMedium => AppTextStyles.displayMedium(color: c ?? AppColors.onBackground),
        AppTextVariant.displaySmall => AppTextStyles.displaySmall(color: c ?? AppColors.onBackground),
        AppTextVariant.headline => AppTextStyles.headline(color: c ?? AppColors.onBackground),
        AppTextVariant.titleLarge => AppTextStyles.titleLarge(color: c ?? AppColors.onSurface),
        AppTextVariant.titleMedium => AppTextStyles.titleMedium(color: c ?? AppColors.onSurface),
        AppTextVariant.titleSmall => AppTextStyles.titleSmall(color: c ?? AppColors.onSurface),
        AppTextVariant.bodyLarge => AppTextStyles.bodyLarge(color: c ?? AppColors.onSurface),
        AppTextVariant.bodyMedium => AppTextStyles.bodyMedium(color: c ?? AppColors.onSurface),
        AppTextVariant.bodySmall => AppTextStyles.bodySmall(color: c ?? AppColors.muted),
        AppTextVariant.labelLarge => AppTextStyles.labelLarge(color: c ?? AppColors.onSurface),
        AppTextVariant.labelMedium => AppTextStyles.labelMedium(color: c ?? AppColors.muted),
        AppTextVariant.labelSmall => AppTextStyles.labelSmall(color: c ?? AppColors.muted),
        AppTextVariant.button => AppTextStyles.button(color: c ?? AppColors.onPrimary),
      };

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _style(color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

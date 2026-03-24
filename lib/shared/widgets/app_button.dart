import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

enum AppButtonSize { small, medium, large }

/// Design-system button with loading state, icon support, and three variants.
///
/// - [primary]   — filled with theme primary color
/// - [secondary] — outlined with primary border
/// - [ghost]     — text-only, no background/border
/// - [danger]    — filled with error color
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool expanded;

  double get _height => switch (size) {
        AppButtonSize.small => 40,
        AppButtonSize.medium => 52,
        AppButtonSize.large => 60,
      };

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 16),
        AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 24),
        AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 32),
      };

  double get _fontSize => switch (size) {
        AppButtonSize.small => 13,
        AppButtonSize.medium => 15,
        AppButtonSize.large => 17,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final (bgColor, fgColor, borderColor) = switch (variant) {
      AppButtonVariant.primary => (cs.primary, cs.onPrimary, Colors.transparent),
      AppButtonVariant.secondary => (Colors.transparent, cs.primary, cs.primary),
      AppButtonVariant.ghost => (Colors.transparent, cs.primary, Colors.transparent),
      AppButtonVariant.danger => (AppColors.error, AppColors.onBackground, Colors.transparent),
    };

    final shape = RoundedRectangleBorder(
      borderRadius: AppSpacing.radiusMd,
      side: borderColor == Colors.transparent
          ? BorderSide.none
          : BorderSide(color: borderColor, width: 1.5),
    );

    final minSize = Size(expanded ? double.infinity : 0, _height);

    final Widget content = isLoading
        ? SizedBox(
            width: _fontSize + 4,
            height: _fontSize + 4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fgColor,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _fontSize + 2, color: fgColor),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTextStyles.button(color: fgColor).copyWith(fontSize: _fontSize),
              ),
            ],
          );

    final style = switch (variant) {
      AppButtonVariant.ghost || AppButtonVariant.secondary => OutlinedButton.styleFrom(
          foregroundColor: fgColor,
          backgroundColor: bgColor,
          minimumSize: minSize,
          padding: _padding,
          shape: shape,
          elevation: 0,
          side: borderColor == Colors.transparent
              ? BorderSide.none
              : BorderSide(color: borderColor, width: 1.5),
        ),
      _ => ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          minimumSize: minSize,
          padding: _padding,
          shape: shape,
          elevation: 0,
        ),
    };

    final callback = (isLoading || onPressed == null)
        ? null
        : () {
            HapticFeedback.mediumImpact();
            onPressed!();
          };

    return switch (variant) {
      AppButtonVariant.ghost || AppButtonVariant.secondary => OutlinedButton(
          key: key,
          onPressed: callback,
          style: style,
          child: content,
        ),
      _ => ElevatedButton(
          key: key,
          onPressed: callback,
          style: style,
          child: content,
        ),
    };
  }
}

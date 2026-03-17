import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderColor,
    this.blur = 8.0,
    this.backgroundColor,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double blur;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.radiusLg;

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: gradient,
                color: backgroundColor ?? AppColors.surface.withValues(alpha: 0.9),
                border: Border.all(
                  color: borderColor ?? AppColors.surfaceBorder,
                  width: 1,
                ),
              ),
              padding: padding ?? AppSpacing.cardPadding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

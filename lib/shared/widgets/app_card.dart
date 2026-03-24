import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import 'tappable.dart';

/// Lightweight card without backdrop blur — complement to [GlassCard].
///
/// Uses the theme's [CardTheme] surface color and elevation.
/// For hero/highlighted sections with glassmorphism, use [GlassCard] instead.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.gradient,
    this.color,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Gradient? gradient;

  /// Override the card background color; defaults to [CardTheme.color].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;
    final radius = borderRadius ?? AppSpacing.radiusLg;
    final bg = color ?? cardTheme.color ?? theme.colorScheme.surface;

    Widget card = Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: gradient,
        color: gradient == null ? bg : null,
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
        boxShadow: cardTheme.elevation != null && cardTheme.elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(
          padding: padding ?? AppSpacing.cardPadding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      card = Tappable(onTap: onTap!, child: card);
    }

    return card;
  }
}

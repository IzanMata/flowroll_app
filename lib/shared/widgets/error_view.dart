import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_strings.dart';
import '../../core/theme/app_text_styles.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.message,
    this.onRetry,
    this.icon,
  });

  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(36),
              ),
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                color: AppColors.error,
                size: 36,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                .scale(begin: const Offset(0.7, 0.7), curve: Curves.elasticOut, duration: 500.ms),
            const SizedBox(height: 16),
            Text(
              message ?? AppStrings.error,
              style: AppTextStyles.bodyMedium(color: AppColors.muted),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 350.ms)
                .slideY(begin: 0.15, curve: Curves.easeOut, duration: 350.ms),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(AppStrings.retry),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(160, 44),
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 300.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOut, duration: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    this.message,
    this.icon,
    this.action,
    this.actionLabel,
  });

  final String? message;
  final IconData? icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(44),
              ),
              child: Icon(
                icon ?? Icons.inbox_rounded,
                color: AppColors.muted,
                size: 44,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                .scale(begin: const Offset(0.75, 0.75), curve: Curves.elasticOut, duration: 550.ms),
            const SizedBox(height: 20),
            Text(
              message ?? AppStrings.empty,
              style: AppTextStyles.bodyMedium(color: AppColors.muted),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 350.ms)
                .slideY(begin: 0.15, curve: Curves.easeOut, duration: 350.ms),
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: action,
                style: ElevatedButton.styleFrom(minimumSize: const Size(160, 44)),
                child: Text(actionLabel!),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 300.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOut, duration: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}

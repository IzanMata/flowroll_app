import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/tatami_provider.dart';

class WeightClassesScreen extends ConsumerWidget {
  const WeightClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(weightClassesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.weightClasses, style: AppTextStyles.titleLarge()),
      ),
      body: classesAsync.when(
        loading: () => const ShimmerList(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(weightClassesProvider),
        ),
        data: (page) {
          if (page.results.isEmpty) {
            return const EmptyView(
              icon: Icons.scale_rounded,
              message: 'No weight classes defined',
            );
          }
          return ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: page.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final wc = page.results[i];
              return GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.scale_rounded, color: AppColors.tertiary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(wc.name, style: AppTextStyles.titleSmall())),
                    if (wc.maxKg != null)
                      Text('≤ ${wc.maxKg}kg', style: AppTextStyles.bodySmall()),
                    if (wc.gender != null) ...[
                      const SizedBox(width: 8),
                      Text(wc.gender!, style: AppTextStyles.labelSmall()),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

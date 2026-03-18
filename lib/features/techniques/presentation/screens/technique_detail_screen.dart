import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/technique.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/techniques_provider.dart';

class TechniqueDetailScreen extends ConsumerWidget {
  const TechniqueDetailScreen({super.key, required this.techniqueId});

  final int techniqueId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final techniqueAsync = ref.watch(techniqueDetailProvider(techniqueId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Technique', style: AppTextStyles.titleLarge())),
      body: techniqueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (technique) {
          final beltColor = AppColors.beltColor(technique.minBelt);
          return SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Belt accent bar
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: beltColor,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(color: beltColor.withValues(alpha: 0.5), blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(technique.name, style: AppTextStyles.titleLarge()),
                if (technique.categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      technique.categories.map((c) => c.name).join(' · '),
                      style: AppTextStyles.bodySmall(color: AppColors.muted),
                    ),
                  ),
                const SizedBox(height: 20),
                if (technique.description != null && technique.description!.isNotEmpty) ...[
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description', style: AppTextStyles.titleSmall()),
                        const SizedBox(height: 8),
                        Text(technique.description!, style: AppTextStyles.bodyMedium()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (technique.variations.isNotEmpty) ...[
                  Text('Variations', style: AppTextStyles.titleSmall()),
                  const SizedBox(height: 8),
                  ...technique.variations.map((v) => _VariationCard(variation: v)),
                  const SizedBox(height: 12),
                ],
                if (technique.leadsTo.isNotEmpty) ...[
                  Text('Leads To', style: AppTextStyles.titleSmall()),
                  const SizedBox(height: 8),
                  ...technique.leadsTo.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_forward_rounded,
                                  color: AppColors.tertiary, size: 16),
                              const SizedBox(width: 10),
                              Text(f.toTechnique, style: AppTextStyles.titleSmall()),
                              if (f.description != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(f.description!,
                                      style: AppTextStyles.bodySmall(), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )),
                ],
                const SizedBox(height: 12),
                GlassCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Min. Belt', style: AppTextStyles.bodyMedium(color: AppColors.muted)),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: beltColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: beltColor.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            technique.minBelt[0].toUpperCase() +
                                technique.minBelt.substring(1),
                            style: AppTextStyles.titleSmall(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VariationCard extends StatelessWidget {
  const _VariationCard({required this.variation});

  final TechniqueVariation variation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(top: 6, right: 10),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(variation.name, style: AppTextStyles.titleSmall()),
                  if (variation.description != null)
                    Text(variation.description!, style: AppTextStyles.bodySmall()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

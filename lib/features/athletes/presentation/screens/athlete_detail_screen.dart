import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/belt_badge.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/athletes_provider.dart';

class AthleteDetailScreen extends ConsumerWidget {
  const AthleteDetailScreen({super.key, required this.athleteId});

  final int athleteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final athleteAsync = ref.watch(athleteDetailProvider(athleteId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: athleteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (athlete) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: DecoratedBox(
                  decoration: const BoxDecoration(gradient: AppColors.cardGradient),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Hero(
                        tag: 'athlete-${athlete.id}',
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            athlete.username.substring(0, 1).toUpperCase(),
                            style: AppTextStyles.displaySmall(color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(athlete.username, style: AppTextStyles.titleLarge()),
                      Text(athlete.email, style: AppTextStyles.bodySmall()),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                  onPressed: () => context.push('/athletes/$athleteId/edit'),
                ),
              ],
            ),
            SliverPadding(
              padding: AppSpacing.screenPadding,
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Belt Rank', style: AppTextStyles.labelMedium()),
                        const SizedBox(height: 12),
                        if (athlete.belt != null)
                          BeltBadge(
                            belt: athlete.belt!,
                            stripes: athlete.stripes ?? 0,
                            size: BeltBadgeSize.large,
                          )
                        else
                          Text('No belt assigned', style: AppTextStyles.bodyMedium(color: AppColors.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Column(
                      children: [
                        _InfoRow(label: 'Role', value: athlete.role?.name ?? 'Student'),
                        const Divider(height: 20),
                        _InfoRow(
                          label: 'Academy',
                          value: athlete.academyDetail.name,
                        ),
                        if (athlete.academyDetail.city != null) ...[
                          const Divider(height: 20),
                          _InfoRow(label: 'City', value: athlete.academyDetail.city!),
                        ],
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium(color: AppColors.muted)),
        Text(value, style: AppTextStyles.titleSmall()),
      ],
    );
  }
}

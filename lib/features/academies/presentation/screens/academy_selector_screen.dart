import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/academy.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tappable.dart';
import '../../domain/academies_provider.dart';

class AcademySelectorScreen extends ConsumerWidget {
  const AcademySelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academiesAsync = ref.watch(academiesProvider(const AcademiesFilter()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.selectAcademy, style: AppTextStyles.titleLarge()),
      ),
      body: academiesAsync.when(
        loading: () => const ShimmerList(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(academiesProvider(const AcademiesFilter())),
        ),
        data: (page) {
          if (page.results.isEmpty) {
            return const EmptyView(
              icon: Icons.school_rounded,
              message: 'No academies found',
            );
          }
          return ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: page.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _AcademyCard(academy: page.results[i]),
          );
        },
      ),
    );
  }
}

class _AcademyCard extends ConsumerWidget {
  const _AcademyCard({required this.academy});

  final Academy academy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedAcademyIdProvider);
    final isSelected = selectedId == academy.id;

    return Tappable(
      onTap: () async {
        await ref.read(selectedAcademyIdProvider.notifier).select(academy.id);
        if (context.mounted) context.go('/home');
      },
      child: GlassCard(
        borderColor: isSelected ? AppColors.primary : AppColors.surfaceBorder,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.sports_mma_rounded,
                color: isSelected ? AppColors.onPrimary : AppColors.muted,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(academy.name, style: AppTextStyles.titleMedium()),
                  if (academy.city != null)
                    Text(academy.city!, style: AppTextStyles.bodySmall()),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.onPrimary, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

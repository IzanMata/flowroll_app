import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/tatami.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tappable.dart';
import '../../domain/tatami_provider.dart';

class TimerPresetsScreen extends ConsumerWidget {
  const TimerPresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academyId = ref.watch(selectedAcademyIdProvider) ?? 0;
    final presetsAsync = ref.watch(timerPresetsProvider(academyId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.timerPresets, style: AppTextStyles.titleLarge()),
      ),
      body: presetsAsync.when(
        loading: () => const ShimmerList(count: 4),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(timerPresetsProvider(academyId)),
        ),
        data: (page) {
          if (page.results.isEmpty) {
            return const EmptyView(
              icon: Icons.timer_rounded,
              message: 'No timer presets',
            );
          }
          return ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: page.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _PresetCard(preset: page.results[i]),
          );
        },
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({required this.preset});

  final TimerPreset preset;

  String get _duration {
    final secs = preset.roundDurationSeconds ?? 0;
    if (secs == 0) return '--';
    final m = secs ~/ 60;
    final s = secs % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.timer_rounded, color: AppColors.tertiary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(preset.name, style: AppTextStyles.titleSmall()),
                Text(
                  '${preset.format?.value ?? 'Custom'}  ·  $_duration per round${preset.rounds != null ? '  ·  ${preset.rounds} rounds' : ''}',
                  style: AppTextStyles.bodySmall(),
                ),
                if (preset.restDurationSeconds != null &&
                    preset.restDurationSeconds! > 0)
                  Text(
                    'Rest: ${preset.restDurationSeconds}s',
                    style: AppTextStyles.bodySmall(color: AppColors.muted),
                  ),
              ],
            ),
          ),
          Tappable(
            onTap: () => context.push('/tatami/timers/${preset.id}/session'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppStrings.startTimer,
                style: AppTextStyles.button(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/tatami_provider.dart';

class MatchupsScreen extends ConsumerWidget {
  const MatchupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academyId = ref.watch(selectedAcademyIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.tatami, style: AppTextStyles.titleLarge()),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined, color: AppColors.primary),
            onPressed: () => context.push('/tatami/timers'),
            tooltip: AppStrings.timerPresets,
          ),
          IconButton(
            icon: const Icon(Icons.scale_rounded, color: AppColors.muted),
            onPressed: () => context.push('/tatami/weights'),
            tooltip: AppStrings.weightClasses,
          ),
        ],
      ),
      body: academyId == null
          ? EmptyView(
              icon: Icons.grid_view_rounded,
              message: 'Select an academy',
              action: () => context.push('/select-academy'),
              actionLabel: AppStrings.selectAcademy,
            )
          : _MatchupsList(academyId: academyId),
      floatingActionButton: academyId != null
          ? FloatingActionButton.extended(
              onPressed: () => _showPairAthletesSheet(context, ref, academyId),
              icon: const Icon(Icons.group_rounded),
              label: const Text(AppStrings.pairAthletes),
            )
          : null,
    );
  }

  void _showPairAthletesSheet(BuildContext context, WidgetRef ref, int academyId) {
    final athletesCtrl = TextEditingController();
    MatchFormatEnum format = MatchFormatEnum.tournament;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.pairAthletes, style: AppTextStyles.titleLarge()),
              const SizedBox(height: 16),
              TextField(
                controller: athletesCtrl,
                style: AppTextStyles.bodyMedium(),
                decoration: const InputDecoration(
                  labelText: 'Athlete IDs (comma separated)',
                  hintText: '1, 2, 3, 4',
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<MatchFormatEnum>(
                segments: const [
                  ButtonSegment(value: MatchFormatEnum.tournament, label: Text('Tournament')),
                  ButtonSegment(value: MatchFormatEnum.survival, label: Text('Survival')),
                ],
                selected: {format},
                onSelectionChanged: (s) => setModalState(() => format = s.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  selectedForegroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final ids = athletesCtrl.text
                      .split(',')
                      .map((s) => int.tryParse(s.trim()))
                      .whereType<int>()
                      .toList();
                  if (ids.length < 2) return;
                  try {
                    await ref.read(tatamiRepositoryProvider).pairAthletes(
                          athleteIds: ids,
                          matchFormat: format,
                          academyId: academyId,
                        );
                    ref.invalidate(matchupsProvider(MatchupsFilter(academyId: academyId)));
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                child: const Text('Create Matchups'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchupsList extends ConsumerWidget {
  const _MatchupsList({required this.academyId});

  final int academyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = MatchupsFilter(academyId: academyId);
    final matchupsAsync = ref.watch(matchupsProvider(filter));

    return matchupsAsync.when(
      loading: () => const ShimmerList(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(matchupsProvider(filter)),
      ),
      data: (page) {
        if (page.results.isEmpty) {
          return const EmptyView(
            icon: Icons.grid_view_rounded,
            message: 'No matchups yet',
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async => ref.invalidate(matchupsProvider(filter)),
          child: ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: page.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _MatchupCard(matchup: page.results[i]),
          ),
        );
      },
    );
  }
}

class _MatchupCard extends StatelessWidget {
  const _MatchupCard({required this.matchup});

  final Matchup matchup;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  matchup.athleteAName,
                  style: AppTextStyles.titleSmall(),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('VS', style: AppTextStyles.labelMedium()),
              ),
              Expanded(
                child: Text(
                  matchup.athleteBName,
                  style: AppTextStyles.titleSmall(),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (matchup.status != null) StatusBadge.matchupStatus(matchup.status!),
              if (matchup.matchFormat != null)
                Text(
                  matchup.matchFormat == MatchFormatEnum.tournament
                      ? 'Tournament'
                      : 'Survival',
                  style: AppTextStyles.labelSmall(),
                ),
              if (matchup.roundNumber != null)
                Text(
                  'Round ${matchup.roundNumber}',
                  style: AppTextStyles.labelSmall(color: AppColors.muted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

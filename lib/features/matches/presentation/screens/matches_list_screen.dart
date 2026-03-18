import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/match.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tappable.dart';
import '../../domain/matches_provider.dart';

class MatchesListScreen extends ConsumerStatefulWidget {
  const MatchesListScreen({super.key});

  @override
  ConsumerState<MatchesListScreen> createState() => _MatchesListScreenState();
}

class _MatchesListScreenState extends ConsumerState<MatchesListScreen> {
  Future<void> _createMatch(BuildContext context) async {
    final aCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    final academyId = ref.read(selectedAcademyIdProvider);
    if (academyId == null) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
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
            Text('New Match', style: AppTextStyles.titleLarge()),
            const SizedBox(height: 16),
            TextField(
              controller: aCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Athlete A ID'),
              style: AppTextStyles.bodyLarge(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Athlete B ID'),
              style: AppTextStyles.bodyLarge(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final a = int.tryParse(aCtrl.text);
                final b = int.tryParse(bCtrl.text);
                if (a == null || b == null) return;
                try {
                  final match = await ref.read(matchesRepositoryProvider).createMatch(
                        athleteA: a,
                        athleteB: b,
                        academyId: academyId,
                      );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    context.push('/matches/${match.id}/live');
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                }
              },
              child: const Text('Start Match'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final academyId = ref.watch(selectedAcademyIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.matches, style: AppTextStyles.titleLarge()),
      ),
      body: academyId == null
          ? EmptyView(
              icon: Icons.sports_mma_rounded,
              message: 'Select an academy',
              action: () => context.push('/select-academy'),
              actionLabel: AppStrings.selectAcademy,
            )
          : _MatchesList(academyId: academyId),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createMatch(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Match'),
      ),
    );
  }
}

class _MatchesList extends ConsumerWidget {
  const _MatchesList({required this.academyId});

  final int academyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = MatchesFilter(academyId: academyId);
    final matchesAsync = ref.watch(matchesProvider(filter));

    return matchesAsync.when(
      loading: () => const ShimmerList(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(matchesProvider(filter)),
      ),
      data: (page) {
        if (page.results.isEmpty) {
          return const EmptyView(
            icon: Icons.sports_mma_rounded,
            message: AppStrings.noMatches,
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async => ref.invalidate(matchesProvider(filter)),
          child: ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: page.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _MatchCard(match: page.results[i]),
          ),
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => context.push(
        match.isFinished ? '/matches/${match.id}' : '/matches/${match.id}/live',
      ),
      child: GlassCard(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(match.athleteADetail.username,
                          style: AppTextStyles.titleSmall(), textAlign: TextAlign.center),
                      Text(
                        '${match.scoreA}',
                        style: AppTextStyles.displaySmall(
                          color: match.scoreA > match.scoreB
                              ? AppColors.primary
                              : AppColors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('VS',
                        style: AppTextStyles.labelMedium(color: AppColors.muted)),
                    const SizedBox(height: 4),
                    if (match.isFinished)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('FINISHED',
                            style: AppTextStyles.labelSmall(color: AppColors.success)),
                      )
                    else
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(match.athleteBDetail.username,
                          style: AppTextStyles.titleSmall(), textAlign: TextAlign.center),
                      Text(
                        '${match.scoreB}',
                        style: AppTextStyles.displaySmall(
                          color: match.scoreB > match.scoreA
                              ? AppColors.primary
                              : AppColors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMM d, h:mm a').format(match.date),
                  style: AppTextStyles.bodySmall(),
                ),
                if (match.winner != null && match.winnerDetail != null) ...[
                  const Text(' · ', style: TextStyle(color: AppColors.muted)),
                  const Icon(Icons.emoji_events_rounded,
                      color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  Text(match.winnerDetail!.username,
                      style: AppTextStyles.bodySmall(color: AppColors.primary)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

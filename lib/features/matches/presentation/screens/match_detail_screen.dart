import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/match.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/matches_provider.dart';

class MatchDetailScreen extends ConsumerWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final int matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academyId = ref.watch(selectedAcademyIdProvider) ?? 0;
    final matchAsync = ref.watch(matchDetailProvider(
      MatchDetailParams(id: matchId, academyId: academyId),
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Match Detail', style: AppTextStyles.titleLarge()),
      ),
      body: matchAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (match) => SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MatchHeader(match: match),
              const SizedBox(height: 20),
              Text('Event Log', style: AppTextStyles.titleSmall()),
              const SizedBox(height: 12),
              ...match.events.map((e) => _EventRow(
                    event: e,
                    isAthleteA: e.athlete == match.athleteA,
                  )),
              if (match.events.isEmpty)
                const EmptyView(
                  icon: Icons.timeline_rounded,
                  message: 'No events recorded',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchHeader extends StatelessWidget {
  const _MatchHeader({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(match.athleteADetail.username, style: AppTextStyles.titleSmall()),
                    const SizedBox(height: 8),
                    Text('${match.scoreA}',
                        style: AppTextStyles.displayMedium(
                          color: match.winner == match.athleteA
                              ? AppColors.primary
                              : AppColors.onSurface,
                        )),
                  ],
                ),
              ),
              Text('vs', style: AppTextStyles.labelMedium(color: AppColors.muted)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(match.athleteBDetail.username, style: AppTextStyles.titleSmall()),
                    const SizedBox(height: 8),
                    Text('${match.scoreB}',
                        style: AppTextStyles.displayMedium(
                          color: match.winner == match.athleteB
                              ? AppColors.primary
                              : AppColors.onSurface,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (match.winner != null && match.winnerDetail != null) ...[
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded, color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text('Winner: ${match.winnerDetail!.username}',
                    style: AppTextStyles.titleSmall(color: AppColors.primary)),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            DateFormat('EEEE, MMMM d, y · h:mm a').format(match.date),
            style: AppTextStyles.bodySmall(),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.isAthleteA});

  final MatchEvent event;
  final bool isAthleteA;

  Color get _typeColor => switch (event.eventType) {
        EventTypeEnum.points => AppColors.primary,
        EventTypeEnum.advantage => AppColors.tertiary,
        EventTypeEnum.penalty => AppColors.error,
        EventTypeEnum.submission => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: _typeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: _typeColor.withValues(alpha: 0.4), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _typeColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${event.eventType.name.toUpperCase()}${event.pointsAwarded != null && event.pointsAwarded! > 0 ? ' +${event.pointsAwarded}' : ''}',
                        style: AppTextStyles.labelSmall(color: _typeColor),
                      ),
                      const Spacer(),
                      Text('${event.timestamp}s', style: AppTextStyles.bodySmall()),
                    ],
                  ),
                  Text(event.actionDescription, style: AppTextStyles.bodySmall()),
                  Text(event.athleteName,
                      style: AppTextStyles.labelSmall(color: AppColors.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

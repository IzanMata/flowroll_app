import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../shared/models/match.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/matches_provider.dart';

class LiveMatchScreen extends ConsumerStatefulWidget {
  const LiveMatchScreen({super.key, required this.matchId});

  final int matchId;

  @override
  ConsumerState<LiveMatchScreen> createState() => _LiveMatchScreenState();
}

class _LiveMatchScreenState extends ConsumerState<LiveMatchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(liveMatchProvider.notifier).loadMatch(widget.matchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(liveMatchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(AppStrings.liveMatch, style: AppTextStyles.titleLarge()),
        actions: [
          matchState.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (match) => match != null && !match.isFinished
                ? TextButton(
                    onPressed: () => _showFinishDialog(context, match),
                    child: Text(AppStrings.finishMatch,
                        style: AppTextStyles.button(color: AppColors.error)),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: matchState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (match) {
          if (match == null) return const SizedBox.shrink();
          return _LiveMatchBody(match: match);
        },
      ),
    );
  }

  void _showFinishDialog(BuildContext context, Match match) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.declareWinner, style: AppTextStyles.titleLarge()),
            const SizedBox(height: 16),
            _WinnerButton(
              name: match.athleteADetail.username,
              onTap: () {
                Navigator.pop(ctx);
                ref.read(liveMatchProvider.notifier).finishMatch(winnerId: match.athleteA);
              },
            ),
            const SizedBox(height: 10),
            _WinnerButton(
              name: match.athleteBDetail.username,
              onTap: () {
                Navigator.pop(ctx);
                ref.read(liveMatchProvider.notifier).finishMatch(winnerId: match.athleteB);
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(liveMatchProvider.notifier).finishMatch();
              },
              child: const Text('No Winner (Draw)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveMatchBody extends ConsumerWidget {
  const _LiveMatchBody({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Score panel — takes 45% of screen
        Expanded(
          flex: 45,
          child: _ScorePanel(match: match),
        ),
        // Events timeline
        Expanded(
          flex: 55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!match.isFinished)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddEventSheet(context, ref, match),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text(AppStrings.addEvent),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text('Event Timeline', style: AppTextStyles.titleSmall()),
              ),
              Expanded(
                child: match.events.isEmpty
                    ? const EmptyView(icon: Icons.timeline_rounded, message: 'No events yet')
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: match.events.length,
                        itemBuilder: (_, i) {
                          final event = match.events[i];
                          return _EventTile(event: event, matchAthleteA: match.athleteA);
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddEventSheet(BuildContext context, WidgetRef ref, Match match) {
    EventTypeEnum? eventType = EventTypeEnum.points;
    final descCtrl = TextEditingController();

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
              Text(AppStrings.addEvent, style: AppTextStyles.titleLarge()),
              const SizedBox(height: 16),
              // Event type selector
              Wrap(
                spacing: 8,
                children: EventTypeEnum.values.map((e) {
                  final selected = eventType == e;
                  return FilterChip(
                    label: Text(e.name[0].toUpperCase() + e.name.substring(1)),
                    selected: selected,
                    onSelected: (_) => setModalState(() => eventType = e),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: AppTextStyles.bodyMedium(),
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (eventType == null) return;
                        final elapsed = DateTime.now().difference(match.date).inSeconds;
                        try {
                          await ref.read(liveMatchProvider.notifier).addEvent(
                                athleteId: match.athleteA,
                                timestamp: elapsed,
                                actionDescription: descCtrl.text.isEmpty
                                    ? eventType!.name
                                    : descCtrl.text,
                                eventType: eventType!,
                              );
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        }
                      },
                      child: Text(match.athleteADetail.username),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (eventType == null) return;
                        final elapsed = DateTime.now().difference(match.date).inSeconds;
                        try {
                          await ref.read(liveMatchProvider.notifier).addEvent(
                                athleteId: match.athleteB,
                                timestamp: elapsed,
                                actionDescription: descCtrl.text.isEmpty
                                    ? eventType!.name
                                    : descCtrl.text,
                                eventType: eventType!,
                              );
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                      ),
                      child: Text(match.athleteBDetail.username),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  const _ScorePanel({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceVariant],
        ),
        border: const Border(
          bottom: BorderSide(color: AppColors.surfaceBorder),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Athlete A
          Expanded(
            child: _AthleteScore(
              name: match.athleteADetail.username,
              score: match.scoreA,
              isWinner: match.isFinished && match.winner == match.athleteA,
              color: AppColors.primary,
            ),
          ),
          // VS divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('VS', style: AppTextStyles.labelMedium(color: AppColors.muted)),
                const SizedBox(height: 8),
                if (match.isFinished)
                  Icon(Icons.emoji_events_rounded,
                      color: AppColors.primary, size: 28)
                else
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
          // Athlete B
          Expanded(
            child: _AthleteScore(
              name: match.athleteBDetail.username,
              score: match.scoreB,
              isWinner: match.isFinished && match.winner == match.athleteB,
              color: AppColors.secondary,
              rightAlign: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _AthleteScore extends StatelessWidget {
  const _AthleteScore({
    required this.name,
    required this.score,
    required this.isWinner,
    required this.color,
    this.rightAlign = false,
  });

  final String name;
  final int score;
  final bool isWinner;
  final Color color;
  final bool rightAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: rightAlign ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (isWinner) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!rightAlign)
                const Icon(Icons.emoji_events_rounded,
                    color: AppColors.primary, size: 14),
              const SizedBox(width: 4),
              Text('WINNER', style: AppTextStyles.labelSmall(color: AppColors.primary)),
              if (rightAlign) ...[
                const SizedBox(width: 4),
                const Icon(Icons.emoji_events_rounded,
                    color: AppColors.primary, size: 14),
              ],
            ],
          ),
          const SizedBox(height: 4),
        ],
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(anim),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Text(
            '$score',
            key: ValueKey(score),
            style: AppTextStyles.displayLarge(color: color),
            textAlign: rightAlign ? TextAlign.right : TextAlign.left,
          ),
        ),
        Text(
          name,
          style: AppTextStyles.titleSmall(),
          overflow: TextOverflow.ellipsis,
          textAlign: rightAlign ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.matchAthleteA});

  final MatchEvent event;
  final int matchAthleteA;

  Color get _color => switch (event.eventType) {
        EventTypeEnum.points => AppColors.primary,
        EventTypeEnum.advantage => AppColors.tertiary,
        EventTypeEnum.penalty => AppColors.error,
        EventTypeEnum.submission => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) {
    final isA = event.athlete == matchAthleteA;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isA) const Spacer(),
          Container(
            constraints: const BoxConstraints(maxWidth: 240),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _color.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment:
                  isA ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.eventType.name.toUpperCase(),
                      style: AppTextStyles.labelSmall(color: _color),
                    ),
                    if (event.pointsAwarded != null && event.pointsAwarded! > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '+${event.pointsAwarded}',
                        style: AppTextStyles.labelSmall(color: _color),
                      ),
                    ],
                  ],
                ),
                Text(event.actionDescription, style: AppTextStyles.bodySmall()),
                Text(
                  '${event.athleteName} · ${event.timestamp}s',
                  style: AppTextStyles.bodySmall(color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (isA) const Spacer(),
        ],
      ),
    );
  }
}

class _WinnerButton extends StatelessWidget {
  const _WinnerButton({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.emoji_events_rounded, size: 18),
      label: Text(name),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}

import 'package:flowroll_app/features/matches/domain/matches_provider.dart';
import 'package:flowroll_app/features/matches/presentation/screens/match_detail_screen.dart';
import 'package:flowroll_app/shared/models/match.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockMatchesRepository mockRepo;

  setUp(() {
    mockRepo = MockMatchesRepository();
    registerFallbacks();
  });

  List<Override> overrides() => [
        matchesRepositoryProvider.overrideWithValue(mockRepo),
      ];

  group('MatchDetailScreen — rendering', () {
    testWidgets('shows athlete A username', (tester) async {
      mockRepo.stubGetMatch(fakeMatch());

      await tester.pumpApp(
        const MatchDetailScreen(matchId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('athlete_a'), findsOneWidget);
    });

    testWidgets('shows athlete B username', (tester) async {
      mockRepo.stubGetMatch(fakeMatch());

      await tester.pumpApp(
        const MatchDetailScreen(matchId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('athlete_b'), findsOneWidget);
    });

    testWidgets('shows vs separator', (tester) async {
      mockRepo.stubGetMatch(fakeMatch());

      await tester.pumpApp(
        const MatchDetailScreen(matchId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('vs'), findsOneWidget);
    });

    testWidgets('shows winner row when match is finished', (tester) async {
      mockRepo.stubGetMatch(fakeMatch(isFinished: true, winner: 1));

      await tester.pumpApp(
        const MatchDetailScreen(matchId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Winner:'), findsOneWidget);
      expect(find.textContaining('athlete_a'), findsWidgets);
    });

    testWidgets('hides winner row when match is not finished', (tester) async {
      mockRepo.stubGetMatch(fakeMatch(isFinished: false, winner: null));

      await tester.pumpApp(
        const MatchDetailScreen(matchId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Winner:'), findsNothing);
    });

    testWidgets('shows Event Log section header', (tester) async {
      mockRepo.stubGetMatch(fakeMatch());

      await tester.pumpApp(
        const MatchDetailScreen(matchId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Event Log'), findsOneWidget);
    });

    testWidgets('shows empty view when no events', (tester) async {
      mockRepo.stubGetMatch(fakeMatch(events: const []));

      await tester.pumpApp(
        const MatchDetailScreen(matchId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('No events recorded'), findsOneWidget);
    });

    testWidgets('shows event action description when events exist', (tester) async {
      const event = MatchEvent(
        id: 1,
        athlete: 1,
        athleteName: 'athlete_a',
        timestamp: 30,
        actionDescription: 'Takedown',
        eventType: EventTypeEnum.points,
        pointsAwarded: 2,
      );
      mockRepo.stubGetMatch(fakeMatch(events: const [event]));

      await tester.pumpApp(
        const MatchDetailScreen(matchId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Takedown'), findsOneWidget);
    });

    testWidgets('shows event timestamp in seconds', (tester) async {
      const event = MatchEvent(
        id: 1,
        athlete: 1,
        athleteName: 'athlete_a',
        timestamp: 45,
        actionDescription: 'Guard pass',
        eventType: EventTypeEnum.advantage,
      );
      mockRepo.stubGetMatch(fakeMatch(events: const [event]));

      await tester.pumpApp(
        const MatchDetailScreen(matchId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('45s'), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      when(() => mockRepo.getMatch(any(), academyId: any(named: 'academyId')))
          .thenThrow(Exception('Not found'));

      await tester.pumpApp(
        const MatchDetailScreen(matchId: 999),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsOneWidget);
    });
  });

  group('MatchDetailScreen — scores', () {
    testWidgets('shows score for athlete A', (tester) async {
      mockRepo.stubGetMatch(fakeMatch(scoreA: 4, scoreB: 2));

      await tester.pumpApp(
        const MatchDetailScreen(matchId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('4'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}

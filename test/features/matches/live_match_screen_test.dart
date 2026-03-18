import 'package:flowroll_app/core/auth/auth_provider.dart';
import 'package:flowroll_app/features/matches/data/matches_repository.dart';
import 'package:flowroll_app/features/matches/domain/matches_provider.dart';
import 'package:flowroll_app/features/matches/presentation/screens/live_match_screen.dart';
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

  List<Override> _overrides(Match match) => [
        matchesRepositoryProvider.overrideWithValue(mockRepo),
        selectedAcademyIdProvider.overrideWith((ref) => _FixedAcademyNotifier()),
        liveMatchProvider.overrideWith(
          (ref) => _FakeLiveMatchNotifier(match, mockRepo),
        ),
      ];

  group('LiveMatchScreen — rendering', () {
    testWidgets('shows athlete names in score panel', (tester) async {
      final match = fakeMatch();
      mockRepo.stubGetMatch(match);

      await tester.pumpApp(
        LiveMatchScreen(matchId: match.id),
        overrides: _overrides(match),
      );
      await tester.pumpAndSettle();

      expect(find.text('athlete_a'), findsWidgets);
      expect(find.text('athlete_b'), findsWidgets);
    });

    testWidgets('shows scores in score panel', (tester) async {
      final match = fakeMatch(scoreA: 3, scoreB: 1);
      mockRepo.stubGetMatch(match);

      await tester.pumpApp(
        LiveMatchScreen(matchId: match.id),
        overrides: _overrides(match),
      );
      await tester.pumpAndSettle();

      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('shows Add Event button when match is in progress', (tester) async {
      final match = fakeMatch(isFinished: false);
      mockRepo.stubGetMatch(match);

      await tester.pumpApp(
        LiveMatchScreen(matchId: match.id),
        overrides: _overrides(match),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Event'), findsOneWidget);
    });

    testWidgets('hides Add Event button when match is finished', (tester) async {
      final match = fakeMatch(isFinished: true, winner: 1);
      mockRepo.stubGetMatch(match);

      await tester.pumpApp(
        LiveMatchScreen(matchId: match.id),
        overrides: _overrides(match),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Event'), findsNothing);
    });

    testWidgets('shows Finish Match button in appbar for in-progress match', (tester) async {
      final match = fakeMatch(isFinished: false);
      mockRepo.stubGetMatch(match);

      await tester.pumpApp(
        LiveMatchScreen(matchId: match.id),
        overrides: _overrides(match),
      );
      await tester.pumpAndSettle();

      expect(find.text('Finish Match'), findsOneWidget);
    });

    testWidgets('shows empty timeline message when no events', (tester) async {
      final match = fakeMatch(events: []);
      mockRepo.stubGetMatch(match);

      await tester.pumpApp(
        LiveMatchScreen(matchId: match.id),
        overrides: _overrides(match),
      );
      await tester.pumpAndSettle();

      expect(find.text('No events yet'), findsOneWidget);
    });

    testWidgets('shows event tiles for each event', (tester) async {
      final event = MatchEvent(
        id: 1,
        athlete: 1,
        athleteName: 'athlete_a',
        timestamp: 45,
        actionDescription: 'Takedown',
        eventType: EventTypeEnum.points,
        pointsAwarded: 2,
      );
      final match = fakeMatch(events: [event]);
      mockRepo.stubGetMatch(match);

      await tester.pumpApp(
        LiveMatchScreen(matchId: match.id),
        overrides: _overrides(match),
      );
      await tester.pumpAndSettle();

      expect(find.text('Takedown'), findsOneWidget);
      expect(find.text('POINTS'), findsOneWidget);
    });

    testWidgets('shows WINNER label when match is finished', (tester) async {
      final match = fakeMatch(isFinished: true, winner: 1);
      mockRepo.stubGetMatch(match);

      await tester.pumpApp(
        LiveMatchScreen(matchId: match.id),
        overrides: _overrides(match),
      );
      await tester.pumpAndSettle();

      expect(find.text('WINNER'), findsOneWidget);
    });
  });

  group('LiveMatchScreen — Add Event sheet', () {
    testWidgets('tapping Add Event opens bottom sheet', (tester) async {
      final match = fakeMatch(isFinished: false);
      mockRepo.stubGetMatch(match);

      await tester.pumpApp(
        LiveMatchScreen(matchId: match.id),
        overrides: _overrides(match),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Event'));
      await tester.pumpAndSettle();

      expect(find.text('Add Event'), findsWidgets); // title + button
      // Event type chips
      expect(find.text('Points'), findsOneWidget);
      expect(find.text('Advantage'), findsOneWidget);
      expect(find.text('Penalty'), findsOneWidget);
      expect(find.text('Submission'), findsOneWidget);
    });

    testWidgets('shows athlete name buttons in add-event sheet', (tester) async {
      final match = fakeMatch(isFinished: false);
      mockRepo.stubGetMatch(match);

      await tester.pumpApp(
        LiveMatchScreen(matchId: match.id),
        overrides: _overrides(match),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Event'));
      await tester.pumpAndSettle();

      expect(find.text('athlete_a'), findsWidgets);
      expect(find.text('athlete_b'), findsWidgets);
    });
  });

  group('LiveMatchScreen — Finish Match', () {
    testWidgets('tapping Finish opens winner selection sheet', (tester) async {
      final match = fakeMatch(isFinished: false);
      mockRepo.stubGetMatch(match);

      await tester.pumpApp(
        LiveMatchScreen(matchId: match.id),
        overrides: _overrides(match),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Finish Match'));
      await tester.pumpAndSettle();

      expect(find.text('Declare Winner'), findsOneWidget);
      expect(find.text('athlete_a'), findsWidgets);
      expect(find.text('athlete_b'), findsWidgets);
      expect(find.text('No Winner (Draw)'), findsOneWidget);
    });

    testWidgets('tapping No Winner calls finishMatch without winnerId', (tester) async {
      final match = fakeMatch(isFinished: false);
      final finishedMatch = fakeMatch(isFinished: true);
      mockRepo.stubGetMatch(match);
      mockRepo.stubFinishMatch(finishedMatch);

      final notifier = _FakeLiveMatchNotifier(match, mockRepo);

      await tester.pumpApp(
        LiveMatchScreen(matchId: match.id),
        overrides: [
          matchesRepositoryProvider.overrideWithValue(mockRepo),
          selectedAcademyIdProvider.overrideWith((ref) => _FixedAcademyNotifier()),
          liveMatchProvider.overrideWith((ref) => notifier),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Finish Match'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('No Winner (Draw)'));
      await tester.pumpAndSettle();

      expect(notifier.finishCalledWithWinnerId, isNull);
      expect(notifier.finishCalled, isTrue);
    });
  });
}

// ── Test helpers ──────────────────────────────────────────────────────────

class _FixedAcademyNotifier extends SelectedAcademyNotifier {
  _FixedAcademyNotifier() : super() {
    state = 1;
  }
}

class _FakeLiveMatchNotifier extends LiveMatchNotifier {
  _FakeLiveMatchNotifier(this._initialMatch, MatchesRepository repo) : super(repo, 1) {
    state = AsyncValue.data(_initialMatch);
  }

  final Match _initialMatch;
  bool finishCalled = false;
  int? finishCalledWithWinnerId = -1; // sentinel: -1 = not called

  @override
  Future<void> loadMatch(int id) async {
    state = AsyncValue.data(_initialMatch);
  }

  @override
  Future<void> finishMatch({int? winnerId}) async {
    finishCalled = true;
    finishCalledWithWinnerId = winnerId;
    state = AsyncValue.data(
      Match(
        id: _initialMatch.id,
        athleteA: _initialMatch.athleteA,
        athleteB: _initialMatch.athleteB,
        athleteADetail: _initialMatch.athleteADetail,
        athleteBDetail: _initialMatch.athleteBDetail,
        date: _initialMatch.date,
        isFinished: true,
        scoreA: _initialMatch.scoreA,
        scoreB: _initialMatch.scoreB,
        winner: winnerId,
        events: _initialMatch.events,
      ),
    );
  }
}

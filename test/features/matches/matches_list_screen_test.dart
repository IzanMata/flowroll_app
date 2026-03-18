import 'package:flowroll_app/core/auth/auth_provider.dart';
import 'package:flowroll_app/features/matches/domain/matches_provider.dart';
import 'package:flowroll_app/features/matches/presentation/screens/matches_list_screen.dart';
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

  List<Override> overrides({int? academyId = 1}) => [
        matchesRepositoryProvider.overrideWithValue(mockRepo),
        selectedAcademyIdProvider.overrideWith((ref) => _FixedAcademyNotifier(academyId)),
      ];

  group('MatchesListScreen — no academy', () {
    testWidgets('shows select-academy prompt when no academy', (tester) async {
      await tester.pumpApp(
        const MatchesListScreen(),
        overrides: overrides(academyId: null),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select an academy'), findsOneWidget);
    });
  });

  group('MatchesListScreen — rendering', () {
    testWidgets('shows athlete names in match card', (tester) async {
      mockRepo.stubListMatches(fakeMatchesPage([
        fakeMatch(),
      ]));

      await tester.pumpApp(const MatchesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('athlete_a'), findsOneWidget);
      expect(find.text('athlete_b'), findsOneWidget);
    });

    testWidgets('shows VS text', (tester) async {
      mockRepo.stubListMatches(fakeMatchesPage([fakeMatch()]));

      await tester.pumpApp(const MatchesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('VS'), findsOneWidget);
    });

    testWidgets('shows FINISHED badge for finished matches', (tester) async {
      mockRepo.stubListMatches(fakeMatchesPage([
        fakeMatch(isFinished: true, winner: 1),
      ]));

      await tester.pumpApp(const MatchesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('FINISHED'), findsOneWidget);
    });

    testWidgets('shows live indicator for in-progress matches', (tester) async {
      mockRepo.stubListMatches(fakeMatchesPage([fakeMatch(isFinished: false)]));

      await tester.pumpApp(const MatchesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      // Live indicator is a small colored circle, not FINISHED badge
      expect(find.text('FINISHED'), findsNothing);
    });

    testWidgets('shows scores', (tester) async {
      mockRepo.stubListMatches(fakeMatchesPage([
        fakeMatch(scoreA: 4, scoreB: 2),
      ]));

      await tester.pumpApp(const MatchesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('4'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows empty view when no matches', (tester) async {
      mockRepo.stubListMatches(emptyPage());

      await tester.pumpApp(const MatchesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('No matches'), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      when(() => mockRepo.listMatches(
            academyId: any(named: 'academyId'),
            page: any(named: 'page'),
            search: any(named: 'search'),
          )).thenThrow(Exception('timeout'));

      await tester.pumpApp(const MatchesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsOneWidget);
    });

    testWidgets('shows winner name with trophy icon', (tester) async {
      mockRepo.stubListMatches(fakeMatchesPage([
        fakeMatch(isFinished: true, winner: 1, scoreA: 3, scoreB: 0),
      ]));

      await tester.pumpApp(const MatchesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('athlete_a'), findsWidgets);
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
    });
  });

  group('MatchesListScreen — FAB new match', () {
    testWidgets('FAB is always visible (even without academy)', (tester) async {
      await tester.pumpApp(
        const MatchesListScreen(),
        overrides: overrides(academyId: null),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('tapping FAB does nothing when no academy selected', (tester) async {
      await tester.pumpApp(
        const MatchesListScreen(),
        overrides: overrides(academyId: null),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // No bottom sheet should appear (academyId is null, early return in _createMatch)
      expect(find.text('New Match'), findsOneWidget); // only FAB label
    });

    testWidgets('tapping FAB opens new-match bottom sheet', (tester) async {
      mockRepo.stubListMatches(emptyPage());

      await tester.pumpApp(const MatchesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Athlete A ID'), findsOneWidget);
      expect(find.text('Athlete B ID'), findsOneWidget);
      expect(find.text('Start Match'), findsOneWidget);
    });

    testWidgets('does not call createMatch when IDs are empty', (tester) async {
      mockRepo.stubListMatches(emptyPage());

      await tester.pumpApp(const MatchesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Match'));
      await tester.pump();

      verifyNever(() => mockRepo.createMatch(
            athleteA: any(named: 'athleteA'),
            athleteB: any(named: 'athleteB'),
            academyId: any(named: 'academyId'),
          ));
    });

    testWidgets('shows snackbar on createMatch failure', (tester) async {
      mockRepo.stubListMatches(emptyPage());
      mockRepo.stubCreateMatchFails(Exception('Athlete not found'));

      await tester.pumpApp(const MatchesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '1');
      await tester.enterText(fields.at(1), '999');

      await tester.tap(find.text('Start Match'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}

class _FixedAcademyNotifier extends SelectedAcademyNotifier {
  _FixedAcademyNotifier(this._id) : super() {
    state = _id;
  }
  final int? _id;
}

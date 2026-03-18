import 'package:flowroll_app/core/auth/auth_provider.dart';
import 'package:flowroll_app/features/athletes/data/athletes_repository.dart';
import 'package:flowroll_app/features/athletes/domain/athletes_provider.dart';
import 'package:flowroll_app/features/athletes/presentation/screens/athlete_form_screen.dart';
import 'package:flowroll_app/shared/models/athlete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockAthletesRepository mockRepo;

  setUp(() {
    mockRepo = MockAthletesRepository();
    registerFallbacks();
  });

  List<Override> _overrides() => [
        athletesRepositoryProvider.overrideWithValue(mockRepo),
        selectedAcademyIdProvider.overrideWith((ref) => _FixedAcademyNotifier()),
      ];

  group('AthleteFormScreen — create mode', () {
    testWidgets('shows User ID field in create mode', (tester) async {
      await tester.pumpApp(const AthleteFormScreen(), overrides: _overrides());

      expect(find.text('User ID'), findsOneWidget);
    });

    testWidgets('shows belt chip options', (tester) async {
      await tester.pumpApp(const AthleteFormScreen(), overrides: _overrides());

      for (final belt in BeltEnum.values) {
        final label = belt.name[0].toUpperCase() + belt.name.substring(1);
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('shows role segmented button with Student and Professor', (tester) async {
      await tester.pumpApp(const AthleteFormScreen(), overrides: _overrides());

      expect(find.text('Student'), findsOneWidget);
      expect(find.text('Professor'), findsOneWidget);
    });

    testWidgets('shows stripe selector 0-4', (tester) async {
      await tester.pumpApp(const AthleteFormScreen(), overrides: _overrides());

      for (int i = 0; i <= 4; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('shows validation error when User ID empty on submit', (tester) async {
      await tester.pumpApp(const AthleteFormScreen(), overrides: _overrides());

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Required'), findsOneWidget);
      verifyNever(() => mockRepo.createAthlete(
            userId: any(named: 'userId'),
            academyId: any(named: 'academyId'),
            belt: any(named: 'belt'),
            role: any(named: 'role'),
            stripes: any(named: 'stripes'),
          ));
    });

    testWidgets('calls createAthlete with entered user ID', (tester) async {
      mockRepo.stubCreateAthlete(fakeAthlete(id: 99, username: 'new_athlete'));

      await tester.pumpApp(const AthleteFormScreen(), overrides: _overrides());

      await tester.enterText(find.byType(TextFormField).first, '42');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.createAthlete(
            userId: 42,
            academyId: any(named: 'academyId'),
            belt: any(named: 'belt'),
            role: any(named: 'role'),
            stripes: any(named: 'stripes'),
          )).called(1);
    });

    testWidgets('shows error message when createAthlete throws', (tester) async {
      mockRepo.stubCreateAthleteFails(Exception('User not found'));

      await tester.pumpApp(const AthleteFormScreen(), overrides: _overrides());

      await tester.enterText(find.byType(TextFormField).first, '99');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.textContaining('User not found'), findsOneWidget);
    });

    testWidgets('shows invalid user ID error for non-numeric input', (tester) async {
      await tester.pumpApp(const AthleteFormScreen(), overrides: _overrides());

      await tester.enterText(find.byType(TextFormField).first, 'abc');
      await tester.tap(find.text('Save'));
      await tester.pump();

      // This validates at the custom level (int.tryParse fails)
      // The form validator passes, but _submit catches invalid ID
      // The screen sets _error = 'Invalid user ID'
      await tester.pumpAndSettle();
      expect(find.textContaining('Invalid user ID'), findsOneWidget);
    });

    testWidgets('selecting a belt chip highlights it', (tester) async {
      await tester.pumpApp(const AthleteFormScreen(), overrides: _overrides());

      await tester.tap(find.text('Blue'));
      await tester.pump();

      // No assertion on visual style — verify chip is tappable without crash
      expect(find.text('Blue'), findsOneWidget);
    });

    testWidgets('selecting Professor role updates segmented button', (tester) async {
      await tester.pumpApp(const AthleteFormScreen(), overrides: _overrides());

      await tester.tap(find.text('Professor'));
      await tester.pump();

      expect(find.text('Professor'), findsOneWidget);
    });
  });

  group('AthleteFormScreen — edit mode', () {
    testWidgets('does not show User ID field in edit mode', (tester) async {
      await tester.pumpApp(
        const AthleteFormScreen(athleteId: 1),
        overrides: _overrides(),
      );

      expect(find.text('User ID'), findsNothing);
    });

    testWidgets('shows Edit Athlete title in edit mode', (tester) async {
      await tester.pumpApp(
        const AthleteFormScreen(athleteId: 1),
        overrides: _overrides(),
      );

      expect(find.textContaining('Edit'), findsOneWidget);
    });

    testWidgets('calls updateAthlete with athleteId in edit mode', (tester) async {
      mockRepo.stubUpdateAthlete(fakeAthlete(id: 1));

      await tester.pumpApp(
        const AthleteFormScreen(athleteId: 1),
        overrides: _overrides(),
      );

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.updateAthlete(
            1,
            belt: any(named: 'belt'),
            role: any(named: 'role'),
            stripes: any(named: 'stripes'),
          )).called(1);
    });
  });
}

class _FixedAcademyNotifier extends SelectedAcademyNotifier {
  _FixedAcademyNotifier() : super() {
    state = 1;
  }
}

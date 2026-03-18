import 'package:flowroll_app/features/athletes/domain/athletes_provider.dart';
import 'package:flowroll_app/features/athletes/presentation/screens/athlete_detail_screen.dart';
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

  List<Override> overrides() => [
        athletesRepositoryProvider.overrideWithValue(mockRepo),
      ];

  group('AthleteDetailScreen — rendering', () {
    testWidgets('shows athlete username', (tester) async {
      mockRepo.stubGetAthlete(fakeAthlete(username: 'john_doe'));

      await tester.pumpApp(
        const AthleteDetailScreen(athleteId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('john_doe'), findsOneWidget);
    });

    testWidgets('shows athlete email', (tester) async {
      mockRepo.stubGetAthlete(fakeAthlete(email: 'john@example.com'));

      await tester.pumpApp(
        const AthleteDetailScreen(athleteId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('shows Belt Rank section', (tester) async {
      mockRepo.stubGetAthlete(fakeAthlete());

      await tester.pumpApp(
        const AthleteDetailScreen(athleteId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belt Rank'), findsOneWidget);
    });

    testWidgets('shows Role info row', (tester) async {
      mockRepo.stubGetAthlete(fakeAthlete());

      await tester.pumpApp(
        const AthleteDetailScreen(athleteId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Role'), findsOneWidget);
    });

    testWidgets('shows Academy info row with academy name', (tester) async {
      mockRepo.stubGetAthlete(fakeAthlete());

      await tester.pumpApp(
        const AthleteDetailScreen(athleteId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Academy'), findsOneWidget);
      expect(find.text('Test Academy'), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      when(() => mockRepo.getAthlete(any())).thenThrow(Exception('Not found'));

      await tester.pumpApp(
        const AthleteDetailScreen(athleteId: 999),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsOneWidget);
    });
  });

  group('AthleteDetailScreen — edit button', () {
    testWidgets('shows edit icon button in app bar', (tester) async {
      mockRepo.stubGetAthlete(fakeAthlete());

      await tester.pumpApp(
        const AthleteDetailScreen(athleteId: 1),
        overrides: overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    });
  });
}

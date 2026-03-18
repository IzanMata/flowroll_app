import 'package:flowroll_app/core/auth/auth_provider.dart';
import 'package:flowroll_app/features/athletes/domain/athletes_provider.dart';
import 'package:flowroll_app/features/athletes/presentation/screens/athletes_list_screen.dart';
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

  List<Override> overrides({int? academyId = 1}) => [
        athletesRepositoryProvider.overrideWithValue(mockRepo),
        selectedAcademyIdProvider.overrideWith((ref) => _FakeAcademyNotifier(academyId)),
      ];

  group('AthletesListScreen — no academy selected', () {
    testWidgets('shows select-academy prompt when no academy', (tester) async {
      await tester.pumpApp(
        const AthletesListScreen(),
        overrides: overrides(academyId: null),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select an academy to get started'), findsOneWidget);
    });
  });

  group('AthletesListScreen — rendering', () {
    testWidgets('shows athlete username and email', (tester) async {
      mockRepo.stubListAthletes(fakeAthletesPage([
        fakeAthlete(username: 'john_doe', email: 'john@example.com'),
      ]));

      await tester.pumpApp(const AthletesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('john_doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
    });

    testWidgets('shows empty view when no athletes', (tester) async {
      mockRepo.stubListAthletes(emptyPage());

      await tester.pumpApp(const AthletesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('No athletes'), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      when(() => mockRepo.listAthletes(
            academyId: any(named: 'academyId'),
            page: any(named: 'page'),
            search: any(named: 'search'),
            ordering: any(named: 'ordering'),
          )).thenThrow(Exception('timeout'));

      await tester.pumpApp(const AthletesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsOneWidget);
    });

    testWidgets('shows role badge for professor', (tester) async {
      mockRepo.stubListAthletes(fakeAthletesPage([
        fakeAthlete(username: 'prof_jones', role: RoleEnum.professor),
      ]));

      await tester.pumpApp(const AthletesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('Professor'), findsOneWidget);
    });

    testWidgets('shows student role badge', (tester) async {
      mockRepo.stubListAthletes(fakeAthletesPage([
        fakeAthlete(username: 'jane_doe', role: RoleEnum.student),
      ]));

      await tester.pumpApp(const AthletesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('Student'), findsOneWidget);
    });
  });

  group('AthletesListScreen — belt filter chips', () {
    testWidgets('shows "All" filter chip selected by default', (tester) async {
      mockRepo.stubListAthletes(fakeAthletesPage());

      await tester.pumpApp(const AthletesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('tapping belt chip filters athletes', (tester) async {
      mockRepo.stubListAthletes(fakeAthletesPage([
        fakeAthlete(id: 1, username: 'blue_belt', belt: BeltEnum.blue),
        fakeAthlete(id: 2, username: 'white_belt', belt: BeltEnum.white),
      ]));

      await tester.pumpApp(const AthletesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      // Both visible before filter
      expect(find.text('blue_belt'), findsOneWidget);
      expect(find.text('white_belt'), findsOneWidget);

      // Tap Blue chip
      await tester.tap(find.text('Blue'));
      await tester.pump();

      // Only blue belt visible
      expect(find.text('blue_belt'), findsOneWidget);
      expect(find.text('white_belt'), findsNothing);
    });

    testWidgets('tapping active belt chip again clears filter', (tester) async {
      mockRepo.stubListAthletes(fakeAthletesPage([
        fakeAthlete(id: 1, username: 'blue_belt', belt: BeltEnum.blue),
        fakeAthlete(id: 2, username: 'white_belt', belt: BeltEnum.white),
      ]));

      await tester.pumpApp(const AthletesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Blue'));
      await tester.pump();

      // Tap again to clear
      await tester.tap(find.text('Blue'));
      await tester.pump();

      expect(find.text('white_belt'), findsOneWidget);
    });
  });

  group('AthletesListScreen — appbar actions', () {
    testWidgets('shows add athlete icon button', (tester) async {
      mockRepo.stubListAthletes(fakeAthletesPage());

      await tester.pumpApp(const AthletesListScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_add_rounded), findsOneWidget);
    });
  });
}

// Helper notifier that returns a fixed academy ID
class _FakeAcademyNotifier extends SelectedAcademyNotifier {
  _FakeAcademyNotifier(this._id) : super() {
    state = _id;
  }
  final int? _id;
}

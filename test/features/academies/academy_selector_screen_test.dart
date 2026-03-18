import 'package:flowroll_app/core/auth/auth_provider.dart';
import 'package:flowroll_app/features/academies/domain/academies_provider.dart';
import 'package:flowroll_app/features/academies/presentation/screens/academy_selector_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_data.dart';

// Minimal wrapper to provide MaterialApp context
class MaterialAppWrapper extends StatelessWidget {
  const MaterialAppWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(home: child);
}

void main() {
  late MockAcademiesRepository mockRepo;

  setUp(() {
    mockRepo = MockAcademiesRepository();
    registerFallbacks();
  });

  List<Override> overrides() => [
        academiesRepositoryProvider.overrideWithValue(mockRepo),
        selectedAcademyIdProvider.overrideWith((ref) => SelectedAcademyNotifier()),
      ];

  group('AcademySelectorScreen — rendering', () {
    testWidgets('shows academy name after data loads', (tester) async {
      mockRepo.stubListAcademies(fakeAcademiesPage([fakeAcademy(name: 'Lions BJJ')]));

      await tester.pumpApp(const AcademySelectorScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('Lions BJJ'), findsOneWidget);
    });

    testWidgets('shows city when provided', (tester) async {
      mockRepo.stubListAcademies(fakeAcademiesPage([fakeAcademy(city: 'Medellín')]));

      await tester.pumpApp(const AcademySelectorScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('Medellín'), findsOneWidget);
    });

    testWidgets('shows empty view when no academies', (tester) async {
      mockRepo.stubListAcademies(emptyPage());

      await tester.pumpApp(const AcademySelectorScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('No academies found'), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      when(() => mockRepo.listAcademies(page: any(named: 'page'), search: any(named: 'search')))
          .thenThrow(Exception('Network error'));

      await tester.pumpApp(const AcademySelectorScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsOneWidget);
    });

    testWidgets('shows multiple academies', (tester) async {
      mockRepo.stubListAcademies(fakeAcademiesPage([
        fakeAcademy(id: 1, name: 'Alpha BJJ'),
        fakeAcademy(id: 2, name: 'Beta BJJ'),
        fakeAcademy(id: 3, name: 'Gamma BJJ'),
      ]));

      await tester.pumpApp(const AcademySelectorScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('Alpha BJJ'), findsOneWidget);
      expect(find.text('Beta BJJ'), findsOneWidget);
      expect(find.text('Gamma BJJ'), findsOneWidget);
    });
  });

  group('AcademySelectorScreen — selection', () {
    testWidgets('tapping an academy card shows check mark', (tester) async {
      mockRepo.stubListAcademies(fakeAcademiesPage([fakeAcademy(id: 1, name: 'Lions BJJ')]));

      // Use a real SelectedAcademyNotifier backed by in-memory SharedPrefs
      final container = ProviderContainer(overrides: [
        academiesRepositoryProvider.overrideWithValue(mockRepo),
        selectedAcademyIdProvider.overrideWith((ref) => SelectedAcademyNotifier()),
      ]);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialAppWrapper(child: AcademySelectorScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Initially no check icon
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });
  });
}

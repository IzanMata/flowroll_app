import 'package:flowroll_app/features/techniques/domain/techniques_provider.dart';
import 'package:flowroll_app/features/techniques/presentation/screens/techniques_curriculum_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockTechniquesRepository mockRepo;

  setUp(() {
    mockRepo = MockTechniquesRepository();
    registerFallbacks();
  });

  List<Override> overrides() => [
        techniquesRepositoryProvider.overrideWithValue(mockRepo),
      ];

  group('TechniquesCurriculumScreen — rendering', () {
    testWidgets('shows belt tabs', (tester) async {
      mockRepo.stubListTechniques(emptyPage());

      await tester.pumpApp(const TechniquesCurriculumScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('White'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Purple'), findsOneWidget);
      expect(find.text('Brown'), findsOneWidget);
      expect(find.text('Black'), findsOneWidget);
    });

    testWidgets('shows technique name in white belt tab', (tester) async {
      mockRepo.stubListTechniques(fakeTechniquesPage([
        fakeTechnique(name: 'Armbar', minBelt: 'white'),
      ]));

      await tester.pumpApp(const TechniquesCurriculumScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('Armbar'), findsOneWidget);
    });

    testWidgets('shows empty view when no white belt techniques', (tester) async {
      // Return a blue-belt technique only — white tab should be empty
      mockRepo.stubListTechniques(fakeTechniquesPage([
        fakeTechnique(name: 'Triangle', minBelt: 'blue'),
      ]));

      await tester.pumpApp(const TechniquesCurriculumScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('No white belt techniques'), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      when(() => mockRepo.listTechniques(
            page: any(named: 'page'),
            search: any(named: 'search'),
          )).thenThrow(Exception('Server error'));

      await tester.pumpApp(const TechniquesCurriculumScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsOneWidget);
    });
  });

  group('TechniquesCurriculumScreen — search', () {
    testWidgets('shows search bar', (tester) async {
      mockRepo.stubListTechniques(emptyPage());

      await tester.pumpApp(const TechniquesCurriculumScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });
  });
}

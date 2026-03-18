import 'package:flowroll_app/core/auth/auth_provider.dart';
import 'package:flowroll_app/features/attendance/data/attendance_repository.dart';
import 'package:flowroll_app/features/attendance/domain/attendance_provider.dart';
import 'package:flowroll_app/features/attendance/presentation/screens/classes_list_screen.dart';
import 'package:flowroll_app/shared/models/attendance.dart';
import 'package:flowroll_app/shared/models/paginated_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_data.dart';

PaginatedResponse<TrainingClass> fakeClassesPage([List<TrainingClass>? items]) =>
    PaginatedResponse(count: items?.length ?? 1, results: items ?? [fakeClass()]);

void main() {
  late MockAttendanceRepository mockRepo;

  setUp(() {
    mockRepo = MockAttendanceRepository();
    registerFallbacks();
  });

  List<Override> _overrides({int? academyId = 1}) => [
        attendanceRepositoryProvider.overrideWithValue(mockRepo),
        selectedAcademyIdProvider.overrideWith((ref) => _FixedAcademyNotifier(academyId)),
      ];

  group('ClassesListScreen — no academy', () {
    testWidgets('shows select-academy prompt when no academy selected', (tester) async {
      await tester.pumpApp(
        const ClassesListScreen(),
        overrides: _overrides(academyId: null),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select an academy to see classes'), findsOneWidget);
      expect(find.text('Select Academy'), findsOneWidget);
    });

    testWidgets('does not show FAB when no academy', (tester) async {
      await tester.pumpApp(
        const ClassesListScreen(),
        overrides: _overrides(academyId: null),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });

  group('ClassesListScreen — rendering', () {
    testWidgets('shows class title after load', (tester) async {
      when(() => mockRepo.listClasses(
            academyId: any(named: 'academyId'),
            page: any(named: 'page'),
            search: any(named: 'search'),
            classType: any(named: 'classType'),
            scheduledAfter: any(named: 'scheduledAfter'),
            scheduledBefore: any(named: 'scheduledBefore'),
          )).thenAnswer((_) async =>
          fakeClassesPage([fakeClass(title: 'Morning Gi')]));

      await tester.pumpApp(const ClassesListScreen(), overrides: _overrides());
      await tester.pumpAndSettle();

      expect(find.text('Morning Gi'), findsOneWidget);
    });

    testWidgets('shows attendance count badge', (tester) async {
      when(() => mockRepo.listClasses(
            academyId: any(named: 'academyId'),
            page: any(named: 'page'),
            search: any(named: 'search'),
            classType: any(named: 'classType'),
            scheduledAfter: any(named: 'scheduledAfter'),
            scheduledBefore: any(named: 'scheduledBefore'),
          )).thenAnswer((_) async =>
          fakeClassesPage([fakeClass(attendanceCount: 12)]));

      await tester.pumpApp(const ClassesListScreen(), overrides: _overrides());
      await tester.pumpAndSettle();

      expect(find.text('12'), findsOneWidget);
      expect(find.text('checked in'), findsOneWidget);
    });

    testWidgets('shows empty view when no classes today', (tester) async {
      when(() => mockRepo.listClasses(
            academyId: any(named: 'academyId'),
            page: any(named: 'page'),
            search: any(named: 'search'),
            classType: any(named: 'classType'),
            scheduledAfter: any(named: 'scheduledAfter'),
            scheduledBefore: any(named: 'scheduledBefore'),
          )).thenAnswer((_) async => fakeClassesPage([]));

      await tester.pumpApp(const ClassesListScreen(), overrides: _overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('No classes'), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      when(() => mockRepo.listClasses(
            academyId: any(named: 'academyId'),
            page: any(named: 'page'),
            search: any(named: 'search'),
            classType: any(named: 'classType'),
            scheduledAfter: any(named: 'scheduledAfter'),
            scheduledBefore: any(named: 'scheduledBefore'),
          )).thenThrow(Exception('Server error'));

      await tester.pumpApp(const ClassesListScreen(), overrides: _overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsOneWidget);
    });
  });

  group('ClassesListScreen — appbar actions', () {
    testWidgets('shows QR scanner icon button', (tester) async {
      when(() => mockRepo.listClasses(
            academyId: any(named: 'academyId'),
            page: any(named: 'page'),
            search: any(named: 'search'),
            classType: any(named: 'classType'),
            scheduledAfter: any(named: 'scheduledAfter'),
            scheduledBefore: any(named: 'scheduledBefore'),
          )).thenAnswer((_) async => fakeClassesPage([]));

      await tester.pumpApp(const ClassesListScreen(), overrides: _overrides());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);
    });

    testWidgets('shows academy select icon button', (tester) async {
      when(() => mockRepo.listClasses(
            academyId: any(named: 'academyId'),
            page: any(named: 'page'),
            search: any(named: 'search'),
            classType: any(named: 'classType'),
            scheduledAfter: any(named: 'scheduledAfter'),
            scheduledBefore: any(named: 'scheduledBefore'),
          )).thenAnswer((_) async => fakeClassesPage([]));

      await tester.pumpApp(const ClassesListScreen(), overrides: _overrides());

      expect(find.byIcon(Icons.school_rounded), findsOneWidget);
    });
  });

  group('ClassesListScreen — FAB', () {
    testWidgets('shows Drop-ins FAB when academy selected', (tester) async {
      when(() => mockRepo.listClasses(
            academyId: any(named: 'academyId'),
            page: any(named: 'page'),
            search: any(named: 'search'),
            classType: any(named: 'classType'),
            scheduledAfter: any(named: 'scheduledAfter'),
            scheduledBefore: any(named: 'scheduledBefore'),
          )).thenAnswer((_) async => fakeClassesPage([]));

      await tester.pumpApp(const ClassesListScreen(), overrides: _overrides());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.textContaining('Drop'), findsOneWidget);
    });
  });
}

class _FixedAcademyNotifier extends SelectedAcademyNotifier {
  _FixedAcademyNotifier(this._id) : super() {
    state = _id;
  }
  final int? _id;
}

import 'package:flowroll_app/features/attendance/data/attendance_repository.dart';
import 'package:flowroll_app/features/attendance/domain/attendance_provider.dart';
import 'package:flowroll_app/features/attendance/presentation/screens/class_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockAttendanceRepository mockRepo;

  setUp(() {
    mockRepo = MockAttendanceRepository();
    registerFallbacks();
  });

  List<Override> _overrides() => [
        attendanceRepositoryProvider.overrideWithValue(mockRepo),
      ];

  group('ClassDetailScreen — rendering', () {
    testWidgets('shows class title', (tester) async {
      mockRepo.stubGetClass(fakeClass(title: 'Evening No-Gi'));

      await tester.pumpApp(
        const ClassDetailScreen(classId: 1),
        overrides: _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Evening No-Gi'), findsOneWidget);
    });

    testWidgets('shows attendance count', (tester) async {
      mockRepo.stubGetClass(fakeClass(attendanceCount: 7));

      await tester.pumpApp(
        const ClassDetailScreen(classId: 1),
        overrides: _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('7'), findsOneWidget);
      expect(find.text('Checked In'), findsOneWidget);
    });

    testWidgets('shows capacity when set', (tester) async {
      mockRepo.stubGetClass(fakeClass(maxCapacity: 25));

      await tester.pumpApp(
        const ClassDetailScreen(classId: 1),
        overrides: _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('25'), findsOneWidget);
      expect(find.text('Capacity'), findsOneWidget);
    });

    testWidgets('shows Generate QR action button', (tester) async {
      mockRepo.stubGetClass(fakeClass());

      await tester.pumpApp(
        const ClassDetailScreen(classId: 1),
        overrides: _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Generate QR'), findsOneWidget);
    });

    testWidgets('shows Manual Check-In action button', (tester) async {
      mockRepo.stubGetClass(fakeClass());

      await tester.pumpApp(
        const ClassDetailScreen(classId: 1),
        overrides: _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manual Check-In'), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      when(() => mockRepo.getClass(any())).thenThrow(Exception('Server error'));

      await tester.pumpApp(
        const ClassDetailScreen(classId: 1),
        overrides: _overrides(),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsOneWidget);
    });
  });

  group('ClassDetailScreen — manual check-in sheet', () {
    testWidgets('tapping Manual Check-In opens bottom sheet', (tester) async {
      mockRepo.stubGetClass(fakeClass());

      await tester.pumpApp(
        const ClassDetailScreen(classId: 1),
        overrides: _overrides(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manual Check-In'));
      await tester.pumpAndSettle();

      expect(find.text('Athlete ID'), findsOneWidget);
      expect(find.text('Check In'), findsOneWidget);
    });

    testWidgets('tapping Check In with empty field does nothing', (tester) async {
      mockRepo.stubGetClass(fakeClass());

      await tester.pumpApp(
        const ClassDetailScreen(classId: 1),
        overrides: _overrides(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manual Check-In'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check In'));
      await tester.pump();

      verifyNever(() => mockRepo.manualCheckIn(
            athleteId: any(named: 'athleteId'),
            trainingClassId: any(named: 'trainingClassId'),
          ));
    });

    testWidgets('calls manualCheckIn with entered athlete ID', (tester) async {
      mockRepo.stubGetClass(fakeClass());
      mockRepo.stubManualCheckIn();

      await tester.pumpApp(
        const ClassDetailScreen(classId: 1),
        overrides: _overrides(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manual Check-In'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '42');
      await tester.tap(find.text('Check In'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.manualCheckIn(
            athleteId: 42,
            trainingClassId: 1,
          )).called(1);
    });

    testWidgets('shows snackbar on manualCheckIn failure', (tester) async {
      mockRepo.stubGetClass(fakeClass());
      mockRepo.stubManualCheckInFails(Exception('Athlete not enrolled'));

      await tester.pumpApp(
        const ClassDetailScreen(classId: 1),
        overrides: _overrides(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manual Check-In'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '99');
      await tester.tap(find.text('Check In'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}

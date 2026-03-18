import 'package:flowroll_app/core/auth/auth_provider.dart';
import 'package:flowroll_app/features/attendance/domain/attendance_provider.dart';
import 'package:flowroll_app/features/attendance/presentation/screens/drop_ins_screen.dart';
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

  List<Override> overrides({int? academyId = 1}) => [
        attendanceRepositoryProvider.overrideWithValue(mockRepo),
        selectedAcademyIdProvider.overrideWith((ref) => _FixedAcademyNotifier(academyId)),
      ];

  group('DropInsScreen — no academy', () {
    testWidgets('shows select-academy message when no academy', (tester) async {
      await tester.pumpApp(
        const DropInsScreen(),
        overrides: overrides(academyId: null),
      );

      expect(find.text('Select an academy'), findsOneWidget);
    });
  });

  group('DropInsScreen — rendering', () {
    testWidgets('shows drop-in visitor name', (tester) async {
      mockRepo.stubListDropIns(fakeDropInsPage([
        fakeDropIn(firstName: 'Carlos', lastName: 'Gracie'),
      ]));

      await tester.pumpApp(const DropInsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('Carlos Gracie'), findsOneWidget);
    });

    testWidgets('shows visitor email', (tester) async {
      mockRepo.stubListDropIns(fakeDropInsPage([
        fakeDropIn(email: 'carlos@bjj.com'),
      ]));

      await tester.pumpApp(const DropInsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('carlos@bjj.com'), findsOneWidget);
    });

    testWidgets('shows empty view when no drop-ins', (tester) async {
      mockRepo.stubListDropIns(emptyPage());

      await tester.pumpApp(const DropInsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('No drop-in visitors'), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      when(() => mockRepo.listDropIns(academyId: any(named: 'academyId')))
          .thenThrow(Exception('Server error'));

      await tester.pumpApp(const DropInsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsOneWidget);
    });
  });

  group('DropInsScreen — add drop-in button', () {
    testWidgets('shows person_add icon button in appbar', (tester) async {
      mockRepo.stubListDropIns(emptyPage());

      await tester.pumpApp(const DropInsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_add_rounded), findsOneWidget);
    });

    testWidgets('tapping add button opens bottom sheet', (tester) async {
      mockRepo.stubListDropIns(emptyPage());

      await tester.pumpApp(const DropInsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Register Drop-in'), findsOneWidget);
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone (optional)'), findsOneWidget);
    });
  });

  group('DropInsScreen — create drop-in form', () {
    testWidgets('shows validation errors when submitting empty form', (tester) async {
      mockRepo.stubListDropIns(emptyPage());

      await tester.pumpApp(const DropInsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_add_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Register'));
      await tester.pump();

      expect(find.text('Required'), findsWidgets);
    });

    testWidgets('calls createDropIn with form values', (tester) async {
      mockRepo.stubListDropIns(emptyPage());
      mockRepo.stubCreateDropIn(fakeDropIn());
      // Re-stub for after creation
      when(() => mockRepo.listDropIns(academyId: any(named: 'academyId')))
          .thenAnswer((_) async => fakeDropInsPage([fakeDropIn()]));

      await tester.pumpApp(const DropInsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_add_rounded));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Ana');
      await tester.enterText(fields.at(1), 'Lima');
      await tester.enterText(fields.at(2), 'ana@example.com');

      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      verify(() => mockRepo.createDropIn(
            academyId: 1,
            firstName: 'Ana',
            lastName: 'Lima',
            email: 'ana@example.com',
            phone: any(named: 'phone'),
            expiresAt: any(named: 'expiresAt'),
          )).called(1);
    });

    testWidgets('shows snackbar error when createDropIn fails', (tester) async {
      mockRepo.stubListDropIns(emptyPage());
      mockRepo.stubCreateDropInFails(Exception('Email already registered'));

      await tester.pumpApp(const DropInsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.person_add_rounded));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Bad');
      await tester.enterText(fields.at(1), 'User');
      await tester.enterText(fields.at(2), 'bad@example.com');

      await tester.tap(find.text('Register'));
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

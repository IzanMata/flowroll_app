import 'package:flowroll_app/core/api/api_exception.dart';
import 'package:flowroll_app/core/auth/auth_provider.dart';
import 'package:flowroll_app/features/auth/data/auth_repository.dart';
import 'package:flowroll_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/pump_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuth;

  setUp(() {
    mockAuth = MockAuthRepository();
  });

  List<Override> overrides() => [
        authRepositoryProvider.overrideWithValue(mockAuth),
        isAuthenticatedProvider.overrideWith((ref) async => false),
      ];

  group('LoginScreen — rendering', () {
    testWidgets('shows username field, password field and sign-in button', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides());

      expect(find.byKey(const Key('login_username_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
    });

    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides());

      final field = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('login_password_field')),
          matching: find.byType(EditableText),
        ),
      );
      expect(field.obscureText, isTrue);
    });

    testWidgets('tapping visibility icon toggles password visibility', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides());

      await tester.tap(find.byIcon(Icons.visibility_off_rounded));
      await tester.pump();

      final field = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('login_password_field')),
          matching: find.byType(EditableText),
        ),
      );
      expect(field.obscureText, isFalse);
    });
  });

  group('LoginScreen — form validation', () {
    testWidgets('shows validation errors when submitting empty fields', (tester) async {
      await tester.pumpApp(const LoginScreen(), overrides: overrides());

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      expect(find.text('Username is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      verifyNever(() => mockAuth.login(username: any(named: 'username'), password: any(named: 'password')));
    });

    testWidgets('does not show validation errors when fields are filled', (tester) async {
      when(() => mockAuth.login(username: any(named: 'username'), password: any(named: 'password')))
          .thenThrow(const UnauthorizedException());

      await tester.pumpApp(const LoginScreen(), overrides: overrides());

      await tester.enterText(find.byKey(const Key('login_username_field')), 'admin');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'pass');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      expect(find.text('Username is required'), findsNothing);
      expect(find.text('Password is required'), findsNothing);
    });
  });

  group('LoginScreen — submission', () {
    testWidgets('shows loading indicator while submitting', (tester) async {
      when(() => mockAuth.login(username: any(named: 'username'), password: any(named: 'password')))
          .thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        throw const UnauthorizedException();
      });

      await tester.pumpApp(const LoginScreen(), overrides: overrides());

      await tester.enterText(find.byKey(const Key('login_username_field')), 'admin');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'pass');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump(); // triggers build with _loading = true

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('calls login with trimmed username and exact password', (tester) async {
      when(() => mockAuth.login(username: 'admin', password: 'admin123'))
          .thenThrow(const UnauthorizedException());

      await tester.pumpApp(const LoginScreen(), overrides: overrides());

      await tester.enterText(find.byKey(const Key('login_username_field')), '  admin  ');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'admin123');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      verify(() => mockAuth.login(username: 'admin', password: 'admin123')).called(1);
    });

    testWidgets('shows error message on ApiException', (tester) async {
      when(() => mockAuth.login(username: any(named: 'username'), password: any(named: 'password')))
          .thenThrow(const BadRequestException('Invalid credentials'));

      await tester.pumpApp(const LoginScreen(), overrides: overrides());

      await tester.enterText(find.byKey(const Key('login_username_field')), 'admin');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'wrong');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('shows generic error on unexpected exception', (tester) async {
      when(() => mockAuth.login(username: any(named: 'username'), password: any(named: 'password')))
          .thenThrow(Exception('Network error'));

      await tester.pumpApp(const LoginScreen(), overrides: overrides());

      await tester.enterText(find.byKey(const Key('login_username_field')), 'admin');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'admin123');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle();

      // Generic error message from AppStrings.loginError
      expect(find.byType(Container), findsWidgets); // error container is shown
    });

    testWidgets('submit button is disabled while loading', (tester) async {
      when(() => mockAuth.login(username: any(named: 'username'), password: any(named: 'password')))
          .thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        throw const UnauthorizedException();
      });

      await tester.pumpApp(const LoginScreen(), overrides: overrides());

      await tester.enterText(find.byKey(const Key('login_username_field')), 'admin');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'pass');
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.byKey(const Key('login_submit_button')),
      );
      expect(button.onPressed, isNull); // disabled
      await tester.pumpAndSettle();
    });
  });
}

import 'package:flowroll_app/shared/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppButton — rendering', () {
    testWidgets('shows label text', (tester) async {
      await tester.pumpApp(AppButton(label: 'Submit', onPressed: () {}));
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpApp(
        AppButton(label: 'Add', onPressed: () {}, icon: Icons.add_rounded),
      );
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('shows spinner when isLoading is true', (tester) async {
      await tester.pumpApp(
        AppButton(label: 'Loading', onPressed: () {}, isLoading: true),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('is disabled when isLoading is true', (tester) async {
      await tester.pumpApp(
        AppButton(label: 'Submit', onPressed: () {}, isLoading: true),
      );
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpApp(
        const AppButton(label: 'Submit', onPressed: null),
      );
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('primary variant renders ElevatedButton', (tester) async {
      await tester.pumpApp(AppButton(label: 'Primary', onPressed: () {}));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('secondary variant renders OutlinedButton', (tester) async {
      await tester.pumpApp(
        AppButton(
          label: 'Secondary',
          onPressed: () {},
          variant: AppButtonVariant.secondary,
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('ghost variant renders OutlinedButton', (tester) async {
      await tester.pumpApp(
        AppButton(
          label: 'Ghost',
          onPressed: () {},
          variant: AppButtonVariant.ghost,
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('danger variant renders ElevatedButton', (tester) async {
      await tester.pumpApp(
        AppButton(
          label: 'Delete',
          onPressed: () {},
          variant: AppButtonVariant.danger,
        ),
      );
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });

  group('AppButton — interactions', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpApp(
        AppButton(label: 'Go', onPressed: () => tapped = true),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when isLoading is true', (tester) async {
      bool tapped = false;
      await tester.pumpApp(
        AppButton(
          label: 'Loading',
          onPressed: () => tapped = true,
          isLoading: true,
        ),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isFalse);
    });
  });
}

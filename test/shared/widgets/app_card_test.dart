import 'package:flowroll_app/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppCard — rendering', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpApp(
        const AppCard(child: Text('Card Content')),
      );
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('renders without onTap without crashing', (tester) async {
      await tester.pumpApp(
        const AppCard(child: Text('Static Card')),
      );
      expect(find.text('Static Card'), findsOneWidget);
    });

    testWidgets('renders with gradient without crashing', (tester) async {
      await tester.pumpApp(
        AppCard(
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.purple],
          ),
          child: const Text('Gradient Card'),
        ),
      );
      expect(find.text('Gradient Card'), findsOneWidget);
    });

    testWidgets('renders with custom padding without crashing', (tester) async {
      await tester.pumpApp(
        const AppCard(
          padding: EdgeInsets.all(8),
          child: Text('Padded Card'),
        ),
      );
      expect(find.text('Padded Card'), findsOneWidget);
    });
  });

  group('AppCard — interactions', () {
    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpApp(
        AppCard(
          onTap: () => tapped = true,
          child: const Text('Tap Me'),
        ),
      );
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}

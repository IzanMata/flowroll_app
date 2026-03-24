import 'package:flowroll_app/shared/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('GlassCard — rendering', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpApp(
        const GlassCard(child: Text('Glass Content')),
      );
      expect(find.text('Glass Content'), findsOneWidget);
    });

    testWidgets('renders without onTap without crashing', (tester) async {
      await tester.pumpApp(
        const GlassCard(child: SizedBox.shrink()),
      );
      expect(find.byType(GlassCard), findsOneWidget);
    });

    testWidgets('renders with custom padding without crashing', (tester) async {
      await tester.pumpApp(
        const GlassCard(
          padding: EdgeInsets.all(8),
          child: Text('Padded Glass'),
        ),
      );
      expect(find.text('Padded Glass'), findsOneWidget);
    });

    testWidgets('renders with gradient without crashing', (tester) async {
      await tester.pumpApp(
        GlassCard(
          gradient: const LinearGradient(colors: [Colors.blue, Colors.cyan]),
          child: const Text('Gradient Glass'),
        ),
      );
      expect(find.text('Gradient Glass'), findsOneWidget);
    });
  });

  group('GlassCard — interactions', () {
    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpApp(
        GlassCard(
          onTap: () => tapped = true,
          child: const Text('Tap Glass'),
        ),
      );
      await tester.tap(find.text('Tap Glass'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}

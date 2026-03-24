import 'package:flowroll_app/shared/widgets/tappable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('Tappable — rendering', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpApp(
        Tappable(onTap: () {}, child: const Text('Tap Me')),
      );
      expect(find.text('Tap Me'), findsOneWidget);
    });

    testWidgets('wraps child in ScaleTransition', (tester) async {
      await tester.pumpApp(
        Tappable(onTap: () {}, child: const Text('Scale')),
      );
      expect(find.byType(ScaleTransition), findsOneWidget);
    });
  });

  group('Tappable — interactions', () {
    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpApp(
        Tappable(onTap: () => tapped = true, child: const Text('Tap Me')),
      );
      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('calls onLongPress when long pressed', (tester) async {
      bool longPressed = false;
      await tester.pumpApp(
        Tappable(
          onTap: () {},
          onLongPress: () => longPressed = true,
          child: const Text('Hold Me'),
        ),
      );
      await tester.longPress(find.text('Hold Me'));
      await tester.pumpAndSettle();
      expect(longPressed, isTrue);
    });

    testWidgets('does not crash without onLongPress', (tester) async {
      await tester.pumpApp(
        Tappable(onTap: () {}, child: const Text('No Long Press')),
      );
      await tester.longPress(find.text('No Long Press'));
      await tester.pumpAndSettle();
      // no crash
    });
  });
}

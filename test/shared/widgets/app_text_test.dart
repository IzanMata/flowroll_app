import 'package:flowroll_app/shared/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppText — rendering', () {
    testWidgets('renders text content', (tester) async {
      await tester.pumpApp(const AppText('Hello World'));
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('applies custom color', (tester) async {
      await tester.pumpApp(
        const AppText('Colored', color: Colors.red),
      );
      final widget = tester.widget<Text>(find.text('Colored'));
      expect(widget.style?.color, Colors.red);
    });

    testWidgets('applies maxLines', (tester) async {
      await tester.pumpApp(const AppText('Long text', maxLines: 2));
      final widget = tester.widget<Text>(find.text('Long text'));
      expect(widget.maxLines, 2);
    });

    testWidgets('applies textAlign center', (tester) async {
      await tester.pumpApp(
        const AppText('Centered', textAlign: TextAlign.center),
      );
      final widget = tester.widget<Text>(find.text('Centered'));
      expect(widget.textAlign, TextAlign.center);
    });

    testWidgets('applies overflow ellipsis', (tester) async {
      await tester.pumpApp(
        const AppText('Overflow text', overflow: TextOverflow.ellipsis),
      );
      final widget = tester.widget<Text>(find.text('Overflow text'));
      expect(widget.overflow, TextOverflow.ellipsis);
    });

    // Smoke test: each variant renders without crashing
    for (final variant in AppTextVariant.values) {
      testWidgets('variant ${variant.name} renders without crashing', (tester) async {
        await tester.pumpApp(AppText('Test', variant: variant));
        expect(find.text('Test'), findsOneWidget);
      });
    }
  });
}

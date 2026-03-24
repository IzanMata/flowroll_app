import 'package:flowroll_app/core/theme/app_strings.dart';
import 'package:flowroll_app/shared/widgets/app_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  Widget _wrap(Widget child) => Material(child: child);

  group('AppSearchBar — rendering', () {
    testWidgets('shows default hint text', (tester) async {
      await tester.pumpApp(_wrap(const AppSearchBar()));
      expect(find.text(AppStrings.search), findsOneWidget);
    });

    testWidgets('shows custom hint text', (tester) async {
      await tester.pumpApp(
        _wrap(const AppSearchBar(hintText: 'Search athletes...')),
      );
      expect(find.text('Search athletes...'), findsOneWidget);
    });

    testWidgets('shows search icon', (tester) async {
      await tester.pumpApp(_wrap(const AppSearchBar()));
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('does not show clear button when empty', (tester) async {
      await tester.pumpApp(_wrap(const AppSearchBar()));
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('renders TextField', (tester) async {
      await tester.pumpApp(_wrap(const AppSearchBar()));
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('AppSearchBar — interactions', () {
    testWidgets('calls onChanged when text is entered', (tester) async {
      String? lastValue;
      await tester.pumpApp(
        _wrap(AppSearchBar(onChanged: (v) => lastValue = v)),
      );
      await tester.enterText(find.byType(TextField), 'test');
      expect(lastValue, 'test');
    });

    testWidgets('shows clear button after entering text', (tester) async {
      await tester.pumpApp(_wrap(const AppSearchBar()));
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('clears text when clear button is tapped', (tester) async {
      String? lastValue;
      await tester.pumpApp(
        _wrap(AppSearchBar(onChanged: (v) => lastValue = v)),
      );
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(find.byIcon(Icons.close_rounded), findsNothing);
      expect(lastValue, '');
    });

    testWidgets('uses external controller when provided', (tester) async {
      final controller = TextEditingController(text: 'prefilled');
      await tester.pumpApp(
        _wrap(AppSearchBar(controller: controller)),
      );
      expect(find.text('prefilled'), findsOneWidget);
      controller.dispose();
    });
  });
}

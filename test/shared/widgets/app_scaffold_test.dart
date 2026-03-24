import 'package:flowroll_app/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppScaffold — rendering', () {
    testWidgets('renders its body', (tester) async {
      await tester.pumpApp(
        const AppScaffold(body: Text('Body Content')),
      );
      expect(find.text('Body Content'), findsOneWidget);
    });

    testWidgets('renders appBar when provided', (tester) async {
      await tester.pumpApp(
        AppScaffold(
          body: const SizedBox.shrink(),
          appBar: AppBar(title: const Text('My Title')),
        ),
      );
      expect(find.text('My Title'), findsOneWidget);
    });

    testWidgets('renders FAB when provided', (tester) async {
      await tester.pumpApp(
        AppScaffold(
          body: const SizedBox.shrink(),
          floatingActionButton: FloatingActionButton(
            key: const Key('test_fab'),
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      );
      expect(find.byKey(const Key('test_fab')), findsOneWidget);
    });

    testWidgets('renders Scaffold widget', (tester) async {
      await tester.pumpApp(
        const AppScaffold(body: SizedBox.shrink()),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('renders with useGradient true without crashing', (tester) async {
      await tester.pumpApp(
        const AppScaffold(body: Text('Gradient Body'), useGradient: true),
      );
      expect(find.text('Gradient Body'), findsOneWidget);
    });

    testWidgets('applies padding when provided', (tester) async {
      await tester.pumpApp(
        const AppScaffold(
          body: Text('Padded'),
          padding: EdgeInsets.all(16),
        ),
      );
      expect(find.text('Padded'), findsOneWidget);
    });
  });
}

import 'package:flowroll_app/core/theme/app_strings.dart';
import 'package:flowroll_app/shared/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('ErrorView — rendering', () {
    testWidgets('shows default error message', (tester) async {
      await tester.pumpApp(const ErrorView());
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.error), findsOneWidget);
    });

    testWidgets('shows custom message', (tester) async {
      await tester.pumpApp(const ErrorView(message: 'Custom error'));
      await tester.pumpAndSettle();
      expect(find.text('Custom error'), findsOneWidget);
    });

    testWidgets('shows default error icon', (tester) async {
      await tester.pumpApp(const ErrorView());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('shows custom icon when provided', (tester) async {
      await tester.pumpApp(const ErrorView(icon: Icons.wifi_off_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpApp(ErrorView(onRetry: () {}));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.retry), findsOneWidget);
    });

    testWidgets('does not show retry button when onRetry is null', (tester) async {
      await tester.pumpApp(const ErrorView());
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.retry), findsNothing);
    });
  });

  group('ErrorView — interactions', () {
    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      bool retried = false;
      await tester.pumpApp(ErrorView(onRetry: () => retried = true));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.retry));
      await tester.pumpAndSettle();
      expect(retried, isTrue);
    });
  });

  group('EmptyView — rendering', () {
    testWidgets('shows default empty message', (tester) async {
      await tester.pumpApp(const EmptyView());
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.empty), findsOneWidget);
    });

    testWidgets('shows custom message', (tester) async {
      await tester.pumpApp(const EmptyView(message: 'No items found'));
      await tester.pumpAndSettle();
      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('shows default inbox icon', (tester) async {
      await tester.pumpApp(const EmptyView());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.inbox_rounded), findsOneWidget);
    });

    testWidgets('shows custom icon when provided', (tester) async {
      await tester.pumpApp(const EmptyView(icon: Icons.sports_mma_rounded));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.sports_mma_rounded), findsOneWidget);
    });

    testWidgets('shows action button when both action and actionLabel provided', (tester) async {
      await tester.pumpApp(EmptyView(action: () {}, actionLabel: 'Add Item'));
      await tester.pumpAndSettle();
      expect(find.text('Add Item'), findsOneWidget);
    });

    testWidgets('does not show action button when action is null', (tester) async {
      await tester.pumpApp(const EmptyView(actionLabel: 'Add Item'));
      await tester.pumpAndSettle();
      expect(find.text('Add Item'), findsNothing);
    });

    testWidgets('does not show action button when actionLabel is null', (tester) async {
      await tester.pumpApp(EmptyView(action: () {}));
      await tester.pumpAndSettle();
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  group('EmptyView — interactions', () {
    testWidgets('calls action when button is tapped', (tester) async {
      bool acted = false;
      await tester.pumpApp(EmptyView(action: () => acted = true, actionLabel: 'Go'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(acted, isTrue);
    });
  });
}

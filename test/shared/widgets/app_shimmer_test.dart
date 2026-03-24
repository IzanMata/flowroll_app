import 'package:flowroll_app/shared/widgets/app_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppShimmer — rendering', () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpApp(
        const AppShimmer(child: Text('Shimmer')),
      );
      expect(find.text('Shimmer'), findsOneWidget);
    });
  });

  group('ShimmerBox — rendering', () {
    testWidgets('renders with default height without crashing', (tester) async {
      await tester.pumpApp(const ShimmerBox());
      expect(find.byType(ShimmerBox), findsOneWidget);
    });

    testWidgets('renders with custom width and height without crashing', (tester) async {
      await tester.pumpApp(const ShimmerBox(width: 100, height: 24));
      expect(find.byType(ShimmerBox), findsOneWidget);
    });

    testWidgets('renders with custom borderRadius without crashing', (tester) async {
      await tester.pumpApp(const ShimmerBox(height: 20, borderRadius: 4));
      expect(find.byType(ShimmerBox), findsOneWidget);
    });
  });

  group('ShimmerCard — rendering', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          width: 400,
          height: 200,
          child: ShimmerCard(),
        ),
      );
      expect(find.byType(ShimmerCard), findsOneWidget);
    });
  });

  group('ShimmerList — rendering', () {
    testWidgets('renders without crashing with default count', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          height: 800,
          child: ShimmerList(),
        ),
      );
      expect(find.byType(ShimmerCard), findsWidgets);
    });

    testWidgets('renders custom count of shimmer cards', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          height: 800,
          child: ShimmerList(count: 3),
        ),
      );
      expect(find.byType(ShimmerCard), findsNWidgets(3));
    });

    testWidgets('renders non-scrollable list', (tester) async {
      await tester.pumpApp(
        const SizedBox(
          height: 800,
          child: ShimmerList(count: 2),
        ),
      );
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.physics, isA<NeverScrollableScrollPhysics>());
    });
  });
}

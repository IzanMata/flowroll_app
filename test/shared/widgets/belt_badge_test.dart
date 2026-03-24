import 'package:flowroll_app/shared/models/athlete.dart';
import 'package:flowroll_app/shared/widgets/belt_badge.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('BeltBadge — rendering', () {
    testWidgets('shows belt label by default', (tester) async {
      await tester.pumpApp(const BeltBadge(belt: BeltEnum.blue));
      expect(find.text('Blue'), findsOneWidget);
    });

    testWidgets('hides belt label when showLabel is false', (tester) async {
      await tester.pumpApp(
        const BeltBadge(belt: BeltEnum.blue, showLabel: false),
      );
      expect(find.text('Blue'), findsNothing);
    });

    testWidgets('renders without crashing with stripes', (tester) async {
      await tester.pumpApp(
        const BeltBadge(belt: BeltEnum.purple, stripes: 3),
      );
      expect(find.text('Purple'), findsOneWidget);
    });

    testWidgets('renders white belt without crashing', (tester) async {
      await tester.pumpApp(const BeltBadge(belt: BeltEnum.white));
      expect(find.text('White'), findsOneWidget);
    });

    testWidgets('renders black belt without crashing', (tester) async {
      await tester.pumpApp(const BeltBadge(belt: BeltEnum.black));
      expect(find.text('Black'), findsOneWidget);
    });

    // Smoke test: each belt enum renders
    for (final belt in BeltEnum.values) {
      testWidgets('belt ${belt.name} renders without crashing', (tester) async {
        await tester.pumpApp(BeltBadge(belt: belt));
        final expectedLabel =
            belt.name[0].toUpperCase() + belt.name.substring(1);
        expect(find.text(expectedLabel), findsOneWidget);
      });
    }
  });

  group('BeltChip — rendering', () {
    testWidgets('shows belt name', (tester) async {
      await tester.pumpApp(const BeltChip(belt: BeltEnum.blue));
      expect(find.text('Blue'), findsOneWidget);
    });

    testWidgets('renders unselected state without crashing', (tester) async {
      await tester.pumpApp(
        const BeltChip(belt: BeltEnum.white, selected: false),
      );
      expect(find.text('White'), findsOneWidget);
    });

    testWidgets('renders selected state without crashing', (tester) async {
      await tester.pumpApp(
        const BeltChip(belt: BeltEnum.brown, selected: true),
      );
      expect(find.text('Brown'), findsOneWidget);
    });
  });

  group('BeltChip — interactions', () {
    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpApp(
        BeltChip(belt: BeltEnum.blue, onTap: () => tapped = true),
      );
      await tester.tap(find.text('Blue'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}

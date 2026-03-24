import 'package:flowroll_app/shared/models/attendance.dart';
import 'package:flowroll_app/shared/models/tatami.dart';
import 'package:flowroll_app/shared/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('StatusBadge — custom constructor', () {
    testWidgets('shows provided label', (tester) async {
      await tester.pumpApp(
        const StatusBadge(label: 'Custom Status', color: Colors.blue),
      );
      expect(find.text('Custom Status'), findsOneWidget);
    });
  });

  group('StatusBadge.matchupStatus — rendering', () {
    testWidgets('shows Pending for pending status', (tester) async {
      await tester.pumpApp(
        StatusBadge.matchupStatus(MatchupStatusEnum.pending),
      );
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('shows In Progress for inProgress status', (tester) async {
      await tester.pumpApp(
        StatusBadge.matchupStatus(MatchupStatusEnum.inProgress),
      );
      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('shows Completed for completed status', (tester) async {
      await tester.pumpApp(
        StatusBadge.matchupStatus(MatchupStatusEnum.completed),
      );
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('shows Cancelled for cancelled status', (tester) async {
      await tester.pumpApp(
        StatusBadge.matchupStatus(MatchupStatusEnum.cancelled),
      );
      expect(find.text('Cancelled'), findsOneWidget);
    });
  });

  group('StatusBadge.dropInStatus — rendering', () {
    testWidgets('shows Pending for pending status', (tester) async {
      await tester.pumpApp(
        StatusBadge.dropInStatus(DropInVisitorStatusEnum.pending),
      );
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('shows Active for active status', (tester) async {
      await tester.pumpApp(
        StatusBadge.dropInStatus(DropInVisitorStatusEnum.active),
      );
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('shows Expired for expired status', (tester) async {
      await tester.pumpApp(
        StatusBadge.dropInStatus(DropInVisitorStatusEnum.expired),
      );
      expect(find.text('Expired'), findsOneWidget);
    });
  });
}

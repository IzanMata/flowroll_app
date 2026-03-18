import 'package:flowroll_app/core/auth/auth_provider.dart';
import 'package:flowroll_app/features/tatami/domain/tatami_provider.dart';
import 'package:flowroll_app/features/tatami/presentation/screens/timer_presets_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockTatamiRepository mockRepo;

  setUp(() {
    mockRepo = MockTatamiRepository();
    registerFallbacks();
  });

  List<Override> overrides({int? academyId = 1}) => [
        tatamiRepositoryProvider.overrideWithValue(mockRepo),
        selectedAcademyIdProvider.overrideWith((ref) => _FixedAcademyNotifier(academyId)),
      ];

  group('TimerPresetsScreen — rendering', () {
    testWidgets('shows preset name', (tester) async {
      mockRepo.stubListPresets(fakePresetsPage([
        fakeTimerPreset(name: '5 Minute Rounds'),
      ]));

      await tester.pumpApp(const TimerPresetsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('5 Minute Rounds'), findsOneWidget);
    });

    testWidgets('shows formatted duration', (tester) async {
      mockRepo.stubListPresets(fakePresetsPage([
        fakeTimerPreset(roundDurationSeconds: 300), // 5m
      ]));

      await tester.pumpApp(const TimerPresetsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('5m'), findsOneWidget);
    });

    testWidgets('shows Start Timer button for each preset', (tester) async {
      mockRepo.stubListPresets(fakePresetsPage([
        fakeTimerPreset(),
      ]));

      await tester.pumpApp(const TimerPresetsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('Start Timer'), findsOneWidget);
    });

    testWidgets('shows multiple presets with individual Start Timer buttons', (tester) async {
      mockRepo.stubListPresets(fakePresetsPage([
        fakeTimerPreset(id: 1, name: 'Preset A'),
        fakeTimerPreset(id: 2, name: 'Preset B'),
      ]));

      await tester.pumpApp(const TimerPresetsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.text('Preset A'), findsOneWidget);
      expect(find.text('Preset B'), findsOneWidget);
      expect(find.text('Start Timer'), findsNWidgets(2));
    });

    testWidgets('shows empty view when no presets', (tester) async {
      mockRepo.stubListPresets(emptyPage());

      await tester.pumpApp(const TimerPresetsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('No timer presets'), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      when(() => mockRepo.listTimerPresets(academyId: any(named: 'academyId')))
          .thenThrow(Exception('Server error'));

      await tester.pumpApp(const TimerPresetsScreen(), overrides: overrides());
      await tester.pumpAndSettle();

      expect(find.textContaining('Exception'), findsOneWidget);
    });
  });
}

class _FixedAcademyNotifier extends SelectedAcademyNotifier {
  _FixedAcademyNotifier(this._id) : super() {
    state = _id;
  }
  final int? _id;
}

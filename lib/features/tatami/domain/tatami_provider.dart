import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tatami_repository.dart';
import '../../../core/api/providers.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/models/tatami.dart';
import '../../../shared/models/paginated_response.dart';

final tatamiRepositoryProvider = Provider<TatamiRepository>((ref) {
  return TatamiRepository(dio: ref.watch(dioProvider));
});

final matchupsProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<Matchup>, MatchupsFilter>((ref, filter) async {
  return ref.watch(tatamiRepositoryProvider).listMatchups(
        academyId: filter.academyId,
        page: filter.page,
        status: filter.status,
        matchFormat: filter.matchFormat,
        weightClass: filter.weightClass,
      );
});

class MatchupsFilter {
  const MatchupsFilter({
    required this.academyId,
    this.page = 1,
    this.status,
    this.matchFormat,
    this.weightClass,
  });
  final int academyId;
  final int page;
  final MatchupStatusEnum? status;
  final MatchFormatEnum? matchFormat;
  final int? weightClass;

  @override
  bool operator ==(Object other) =>
      other is MatchupsFilter &&
      other.academyId == academyId &&
      other.page == page &&
      other.status == status &&
      other.matchFormat == matchFormat &&
      other.weightClass == weightClass;

  @override
  int get hashCode => Object.hash(academyId, page, status, matchFormat, weightClass);
}

final timerPresetsProvider = FutureProvider.autoDispose.family<PaginatedResponse<TimerPreset>, int>(
    (ref, academyId) async {
  return ref.watch(tatamiRepositoryProvider).listTimerPresets(academyId: academyId);
});

final weightClassesProvider = FutureProvider.autoDispose<PaginatedResponse<WeightClass>>((ref) async {
  return ref.watch(tatamiRepositoryProvider).listWeightClasses();
});

// Timer session state notifier with local countdown
class TimerSessionNotifier extends StateNotifier<TimerSessionState> {
  TimerSessionNotifier(this._repo, this._academyId)
      : super(const TimerSessionState.idle());

  final TatamiRepository _repo;
  final int _academyId;
  Timer? _ticker;
  int _localElapsed = 0;
  int _roundDurationSeconds = 300;

  Future<void> startSession(int presetId) async {
    try {
      state = const TimerSessionState.loading();
      // Fetch preset first to get duration
      final presetsPage = await _repo.listTimerPresets(academyId: _academyId);
      final preset = presetsPage.results.where((p) => p.id == presetId).firstOrNull;
      _roundDurationSeconds = preset?.roundDurationSeconds ?? 300;

      final session = await _repo.startSession(presetId: presetId, academyId: _academyId);
      _localElapsed = session.elapsedSeconds;
      state = TimerSessionState.running(
        session: session,
        localElapsed: _localElapsed,
        totalSeconds: _roundDurationSeconds,
      );
      _startTicker(_roundDurationSeconds);
    } catch (e) {
      state = TimerSessionState.error(e.toString());
    }
  }

  Future<void> pause() async {
    _ticker?.cancel();
    final session = state.session;
    if (session == null) return;
    try {
      final updated = await _repo.pauseSession(sessionId: session.id, academyId: _academyId);
      state = TimerSessionState.paused(session: updated, localElapsed: _localElapsed, totalSeconds: _roundDurationSeconds);
    } catch (e) {
      state = TimerSessionState.error(e.toString());
    }
  }

  Future<void> resume() async {
    final session = state.session;
    if (session == null) return;
    state = TimerSessionState.running(session: session, localElapsed: _localElapsed, totalSeconds: _roundDurationSeconds);
    _startTicker(_roundDurationSeconds);
  }

  Future<void> finish() async {
    _ticker?.cancel();
    final session = state.session;
    if (session == null) return;
    try {
      final updated = await _repo.finishSession(sessionId: session.id, academyId: _academyId);
      state = TimerSessionState.finished(session: updated);
    } catch (e) {
      state = TimerSessionState.error(e.toString());
    }
  }

  void _startTicker(int totalSeconds) {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _localElapsed++;
      final session = state.session;
      if (session != null) {
        state = TimerSessionState.running(
          session: session,
          localElapsed: _localElapsed,
          totalSeconds: _roundDurationSeconds,
        );
        if (_localElapsed >= totalSeconds) {
          _ticker?.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

sealed class TimerSessionState {
  const TimerSessionState();
  const factory TimerSessionState.idle() = _Idle;
  const factory TimerSessionState.loading() = _Loading;
  const factory TimerSessionState.running({
    required TimerSession session,
    required int localElapsed,
    required int totalSeconds,
  }) = _Running;
  const factory TimerSessionState.paused({
    required TimerSession session,
    required int localElapsed,
    required int totalSeconds,
  }) = _Paused;
  const factory TimerSessionState.finished({required TimerSession session}) = _Finished;
  const factory TimerSessionState.error(String message) = _Error;

  TimerSession? get session => switch (this) {
        _Running(session: final s) => s,
        _Paused(session: final s) => s,
        _Finished(session: final s) => s,
        _ => null,
      };

  int get localElapsed => switch (this) {
        _Running(localElapsed: final e) => e,
        _Paused(localElapsed: final e) => e,
        _ => 0,
      };

  int get totalSeconds => switch (this) {
        _Running(totalSeconds: final t) => t,
        _Paused(totalSeconds: final t) => t,
        _ => 300,
      };

  bool get isRunning => this is _Running;
  bool get isPaused => this is _Paused;
  bool get isFinished => this is _Finished;
}

final class _Idle extends TimerSessionState {
  const _Idle();
}

final class _Loading extends TimerSessionState {
  const _Loading();
}

final class _Running extends TimerSessionState {
  const _Running({required this.session, required this.localElapsed, required this.totalSeconds});
  @override
  final TimerSession session;
  @override
  final int localElapsed;
  @override
  final int totalSeconds;
}

final class _Paused extends TimerSessionState {
  const _Paused({required this.session, required this.localElapsed, required this.totalSeconds});
  @override
  final TimerSession session;
  @override
  final int localElapsed;
  @override
  final int totalSeconds;
}

final class _Finished extends TimerSessionState {
  const _Finished({required this.session});
  @override
  final TimerSession session;
}

final class _Error extends TimerSessionState {
  const _Error(this.message);
  final String message;
}

final timerSessionNotifierProvider =
    StateNotifierProvider<TimerSessionNotifier, TimerSessionState>((ref) {
  final academyId = ref.watch(selectedAcademyIdProvider);
  if (academyId == null) return TimerSessionNotifier(ref.watch(tatamiRepositoryProvider), 0);
  return TimerSessionNotifier(ref.watch(tatamiRepositoryProvider), academyId);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/providers.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/models/match.dart';
import '../../../shared/models/paginated_response.dart';
import '../data/matches_repository.dart';

final matchesRepositoryProvider = Provider<MatchesRepository>((ref) {
  return MatchesRepository(dio: ref.watch(dioProvider));
});

final matchesProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<Match>, MatchesFilter>((ref, filter) async {
  return ref.watch(matchesRepositoryProvider).listMatches(
        academyId: filter.academyId,
        page: filter.page,
        search: filter.search,
      );
});

class MatchesFilter {
  const MatchesFilter({required this.academyId, this.page = 1, this.search});
  final int academyId;
  final int page;
  final String? search;

  @override
  bool operator ==(Object other) =>
      other is MatchesFilter &&
      other.academyId == academyId &&
      other.page == page &&
      other.search == search;

  @override
  int get hashCode => Object.hash(academyId, page, search);
}

final matchDetailProvider =
    FutureProvider.autoDispose.family<Match, MatchDetailParams>((ref, params) async {
  return ref.watch(matchesRepositoryProvider).getMatch(params.id, academyId: params.academyId);
});

class MatchDetailParams {
  const MatchDetailParams({required this.id, required this.academyId});
  final int id;
  final int academyId;

  @override
  bool operator ==(Object other) =>
      other is MatchDetailParams && other.id == id && other.academyId == academyId;

  @override
  int get hashCode => Object.hash(id, academyId);
}

// Live match state notifier
class LiveMatchNotifier extends StateNotifier<AsyncValue<Match?>> {
  LiveMatchNotifier(this._repo, this._academyId) : super(const AsyncValue.data(null));

  final MatchesRepository _repo;
  final int _academyId;

  Future<void> loadMatch(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.getMatch(id, academyId: _academyId));
  }

  Future<void> addEvent({
    required int athleteId,
    required int timestamp,
    required String actionDescription,
    required EventTypeEnum eventType,
    int? pointsAwarded,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = await AsyncValue.guard(() => _repo.addEvent(
          matchId: current.id,
          athleteId: athleteId,
          timestamp: timestamp,
          actionDescription: actionDescription,
          eventType: eventType,
          pointsAwarded: pointsAwarded,
          academyId: _academyId,
        ));
  }

  Future<void> finishMatch({int? winnerId}) async {
    final current = state.valueOrNull;
    if (current == null) return;
    state = await AsyncValue.guard(() => _repo.finishMatch(
          matchId: current.id,
          athleteA: current.athleteA,
          athleteB: current.athleteB,
          winnerId: winnerId,
          academyId: _academyId,
        ));
  }
}

final liveMatchProvider =
    StateNotifierProvider.autoDispose<LiveMatchNotifier, AsyncValue<Match?>>((ref) {
  final academyId = ref.watch(selectedAcademyIdProvider) ?? 0;
  return LiveMatchNotifier(ref.watch(matchesRepositoryProvider), academyId);
});

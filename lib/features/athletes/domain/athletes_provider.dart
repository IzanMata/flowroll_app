import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/athletes_repository.dart';
import '../../../core/api/providers.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/models/athlete.dart';
import '../../../shared/models/paginated_response.dart';

final athletesRepositoryProvider = Provider<AthletesRepository>((ref) {
  return AthletesRepository(dio: ref.watch(dioProvider));
});

class AthletesFilter {
  const AthletesFilter({required this.academyId, this.page = 1, this.search, this.ordering});
  final int academyId;
  final int page;
  final String? search;
  final String? ordering;

  @override
  bool operator ==(Object other) =>
      other is AthletesFilter &&
      other.academyId == academyId &&
      other.page == page &&
      other.search == search &&
      other.ordering == ordering;

  @override
  int get hashCode => Object.hash(academyId, page, search, ordering);
}

final athletesProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<AthleteProfile>, AthletesFilter>((ref, filter) async {
  return ref.watch(athletesRepositoryProvider).listAthletes(
        academyId: filter.academyId,
        page: filter.page,
        search: filter.search,
        ordering: filter.ordering,
      );
});

final athleteDetailProvider =
    FutureProvider.autoDispose.family<AthleteProfile, int>((ref, id) async {
  return ref.watch(athletesRepositoryProvider).getAthlete(id);
});

// Convenience provider that uses selected academy
final currentAcademyAthletesProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<AthleteProfile>, String?>((ref, search) async {
  final academyId = ref.watch(selectedAcademyIdProvider);
  if (academyId == null) return PaginatedResponse(count: 0, results: []);
  return ref.watch(athletesRepositoryProvider).listAthletes(
        academyId: academyId,
        search: search,
      );
});

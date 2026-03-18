import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/providers.dart';
import '../../../shared/models/paginated_response.dart';
import '../../../shared/models/technique.dart';
import '../data/techniques_repository.dart';

final techniquesRepositoryProvider = Provider<TechniquesRepository>((ref) {
  return TechniquesRepository(dio: ref.watch(dioProvider));
});

final beltsProvider = FutureProvider.autoDispose<List<Belt>>((ref) async {
  final result = await ref.watch(techniquesRepositoryProvider).listBelts();
  return result.results;
});

final categoriesProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<TechniqueCategory>, String?>((ref, search) async {
  return ref.watch(techniquesRepositoryProvider).listCategories(search: search);
});

final techniquesProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<Technique>, TechniquesFilter>((ref, filter) async {
  return ref.watch(techniquesRepositoryProvider).listTechniques(
        page: filter.page,
        search: filter.search,
      );
});

class TechniquesFilter {
  const TechniquesFilter({this.page = 1, this.search});
  final int page;
  final String? search;

  @override
  bool operator ==(Object other) =>
      other is TechniquesFilter && other.page == page && other.search == search;

  @override
  int get hashCode => Object.hash(page, search);
}

final techniqueDetailProvider =
    FutureProvider.autoDispose.family<Technique, int>((ref, id) async {
  return ref.watch(techniquesRepositoryProvider).getTechnique(id);
});

// Techniques grouped by belt
final techniquesByBeltProvider = FutureProvider.autoDispose
    .family<List<Technique>, String>((ref, beltColor) async {
  final result = await ref.watch(techniquesRepositoryProvider).listTechniques();
  return result.results.where((t) => t.minBelt == beltColor).toList();
});

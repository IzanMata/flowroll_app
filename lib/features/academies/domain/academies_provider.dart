import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/academies_repository.dart';
import '../../../core/api/providers.dart';
import '../../../shared/models/academy.dart';
import '../../../shared/models/paginated_response.dart';

final academiesRepositoryProvider = Provider<AcademiesRepository>((ref) {
  return AcademiesRepository(dio: ref.watch(dioProvider));
});

final academiesProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<Academy>, AcademiesFilter>((ref, filter) async {
  return ref.watch(academiesRepositoryProvider).listAcademies(
        page: filter.page,
        search: filter.search,
      );
});

class AcademiesFilter {
  const AcademiesFilter({this.page = 1, this.search});
  final int page;
  final String? search;

  @override
  bool operator ==(Object other) =>
      other is AcademiesFilter && other.page == page && other.search == search;

  @override
  int get hashCode => Object.hash(page, search);
}

final academyDetailProvider = FutureProvider.autoDispose.family<Academy, int>((ref, id) async {
  return ref.watch(academiesRepositoryProvider).getAcademy(id);
});

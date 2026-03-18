---
name: new_feature
triggers: ["add a feature", "scaffold feature", "new feature"]
description: Protocol for scaffolding a complete feature from scratch in FlowRoll
---

# New Feature Protocol

## Step 1 — Clarify
- Feature name (snake_case)
- Models needed (check `lib/shared/models/` — reuse if exists)
- API endpoints (check `ApiConstants` in `lib/core/api/api_constants.dart`)
- Does it appear in bottom nav shell or as a standalone route?

## Step 2 — Create directory structure
```
lib/features/{feature}/
  data/
    {feature}_repository.dart
  domain/
    {feature}_provider.dart
  presentation/
    screens/
      {feature}_list_screen.dart   (if list)
      {feature}_detail_screen.dart (if detail)
    widgets/                        (feature-scoped widgets)
```

## Step 3 — Model (if new)
File: `lib/shared/models/{feature}.dart`
```dart
class {Model} {
  const {Model}({required this.id, ...});

  final int id;
  // other fields

  factory {Model}.fromJson(Map<String, dynamic> json) => {Model}(
    id: json['id'] as int,
    // ...
  );
}

// Enums if needed:
enum {Field}Enum {
  value1('api_value_1'),
  value2('api_value_2');

  const {Field}Enum(this.value);
  final String value;

  static {Field}Enum fromJson(String v) =>
      {Field}Enum.values.firstWhere((e) => e.value == v, orElse: () => {Field}Enum.value1);
}
```

## Step 4 — Repository
File: `lib/features/{feature}/data/{feature}_repository.dart`
```dart
import 'package:dio/dio.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../shared/models/{feature}.dart';
import '../../../shared/models/paginated_response.dart';

class {Feature}Repository {
  {Feature}Repository({required this.dio});
  final Dio dio;

  Future<PaginatedResponse<{Model}>> list{Models}({
    required int academyId,
    int page = 1,
    String? search,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        ApiConstants.{feature}Path,
        queryParameters: {
          ApiConstants.academyParam: academyId,
          ApiConstants.pageParam: page,
          if (search != null && search.isNotEmpty) ApiConstants.searchParam: search,
        },
      );
      return PaginatedResponse.fromJson(response.data!, {Model}.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
```
Add `static const String {feature}Path = '/api/{feature}/';` to `ApiConstants`.

## Step 5 — Provider
File: `lib/features/{feature}/domain/{feature}_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/{feature}_repository.dart';
import '../../../core/api/providers.dart';
import '../../../core/auth/auth_provider.dart';

final {feature}RepositoryProvider = Provider<{Feature}Repository>((ref) {
  return {Feature}Repository(dio: ref.watch(dioProvider));
});

class {Feature}Filter {
  const {Feature}Filter({required this.academyId, this.page = 1, this.search});
  final int academyId;
  final int page;
  final String? search;

  @override
  bool operator ==(Object other) =>
      other is {Feature}Filter &&
      other.academyId == academyId &&
      other.page == page &&
      other.search == search;

  @override
  int get hashCode => Object.hash(academyId, page, search);
}

final {feature}Provider = FutureProvider.autoDispose
    .family<PaginatedResponse<{Model}>, {Feature}Filter>((ref, filter) async {
  return ref.watch({feature}RepositoryProvider).list{Models}(
        academyId: filter.academyId,
        page: filter.page,
        search: filter.search,
      );
});
```

## Step 6 — Add route to app_router.dart
See `new_screen` skill for route registration pattern.

## Step 7 — Add to bottom nav (if shell route)
Edit `lib/shared/widgets/main_shell.dart` to include nav destination.

## Step 8 — Test infrastructure
Add to `test/helpers/fake_repositories.dart`:
```dart
class Mock{Feature}Repository extends Mock implements {Feature}Repository {}

extension {Feature}RepoStubs on Mock{Feature}Repository {
  void stubList{Models}(PaginatedResponse<{Model}> page) {
    when(() => list{Models}(
          academyId: any(named: 'academyId'),
          page: any(named: 'page'),
          search: any(named: 'search'),
        )).thenAnswer((_) async => page);
  }
}
```
Add fake factory to `test/helpers/test_data.dart`.

## Checklist
- [ ] Model in `lib/shared/models/`
- [ ] Repository with explicit generic Dio calls (`dio.get<Map<String, dynamic>>()`)
- [ ] ApiConstants entry added
- [ ] Provider with Filter class (== and hashCode)
- [ ] Screen(s) with all 4 states
- [ ] Route registered
- [ ] Mock + stubs added to test helpers
- [ ] `flutter analyze` clean

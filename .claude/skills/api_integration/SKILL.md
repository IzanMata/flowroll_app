---
name: api_integration
triggers: ["connect API endpoint", "wire endpoint", "call API", "integrate endpoint"]
description: Protocol for connecting a new Django REST API endpoint to FlowRoll
---

# API Integration Protocol

## Step 1 — Identify the endpoint
Check `lib/core/api/api_constants.dart` for existing paths.
If new, add: `static const String {name}Path = '/api/{path}/';`

Key patterns:
- List endpoints: `GET /api/{resource}/?academy=<id>&page=<n>`
- Detail: `GET /api/{resource}/<id>/`
- Create: `POST /api/{resource}/`
- Custom action: `POST /api/{resource}/<id>/{action}/`
- Multi-tenancy: most endpoints filter by `?academy=<id>` — use `ApiConstants.academyParam`

## Step 2 — Add to Repository
In `lib/features/{feature}/data/{feature}_repository.dart`:
```dart
Future<{ReturnType}> {methodName}({
  required int academyId,  // if multi-tenant
  // other params
}) async {
  try {
    final response = await dio.{method}<Map<String, dynamic>>(   // always explicit type
      ApiConstants.{name}Path,
      // For POST/PATCH:
      data: {'field': value},
      // For GET with params:
      queryParameters: {
        ApiConstants.academyParam: academyId,
      },
    );
    return {ReturnType}.fromJson(response.data!);
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
}
```

**Dio type rules (strict-inference):**
- `dio.get<Map<String, dynamic>>()` for JSON object responses
- `dio.delete<void>()` for no-content responses
- Access response: `response.data!` (not `response.data as Map<...>`)

## Step 3 — Expose via Provider
**Simple read (FutureProvider):**
```dart
final {resource}DetailProvider =
    FutureProvider.autoDispose.family<{Model}, int>((ref, id) async {
  return ref.watch({feature}RepositoryProvider).get{Model}(id);
});
```

**Mutable state (StateNotifier):**
```dart
class {Name}Notifier extends StateNotifier<AsyncValue<{Model}?>> {
  {Name}Notifier(this._repo, this._academyId) : super(const AsyncValue.loading()) {
    _load();
  }

  final {Feature}Repository _repo;
  final int _academyId;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.get{Model}(...));
  }

  Future<void> {action}({params}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.{action}(...));
  }
}

final {name}Provider = StateNotifierProvider.autoDispose<{Name}Notifier, AsyncValue<{Model}?>>((ref) {
  final academyId = ref.watch(selectedAcademyIdProvider) ?? 0;
  return {Name}Notifier(ref.watch({feature}RepositoryProvider), academyId);
});
```

## Step 4 — Error handling
`ApiException` is a sealed class — catch concrete subtypes:
- `UnauthorizedException` → 401 (JWT interceptor handles auto-refresh; if bubbles up, logout)
- `BadRequestException(message)` → 400 (show message in UI)
- `NotFoundException` → 404 (show error view)
- `NetworkException` → no connection (show retry)
- `ServerException` → 500 (show generic error)

In UI:
```dart
try {
  await ref.read(provider.notifier).doAction();
  if (mounted) ScaffoldMessenger.of(context).showSnackBar(...);
} on ApiException catch (e) {
  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message)),
  );
} catch (e) {
  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
}
```

## Step 5 — JWT Interceptor notes
- Automatically retries on 401 with refreshed token
- `_isAuthEndpoint` checks exact path (`==`), not `contains`
- Queues concurrent requests during refresh
- If refresh fails → clears tokens → user must re-login

## Step 6 — Add stub to test helpers
In `test/helpers/fake_repositories.dart`:
```dart
void stub{Method}({ReturnType} result) {
  when(() => {method}(
        academyId: any(named: 'academyId'),
        // other named params
      )).thenAnswer((_) async => result);
}

void stub{Method}Fails(Exception error) {
  when(() => {method}(
        academyId: any(named: 'academyId'),
      )).thenThrow(error);
}
```

## Checklist
- [ ] Path added to `ApiConstants`
- [ ] Repository method with explicit Dio generic type
- [ ] `response.data!` used (not cast)
- [ ] `DioException` caught, wrapped with `ApiException.fromDio(e)`
- [ ] Provider created (FutureProvider or StateNotifier as appropriate)
- [ ] Error subtypes handled in UI (not just generic `catch`)
- [ ] Stub added to test helpers
- [ ] `flutter analyze` clean

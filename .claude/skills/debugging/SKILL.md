---
name: debugging
triggers: ["fix a bug", "debug this", "something is broken", "fix this error"]
description: Protocol for diagnosing and fixing bugs in FlowRoll
---

# Debugging Protocol

## Step 1 — Read the full error before touching anything
- Stack trace: identify the exact file and line number
- Error type: `TypeError`, `StateError`, `ApiException`, `DioException`, `FlutterError`?
- Is it a runtime error, compile error, or test failure?

## Step 2 — Classify the bug

### Network / API bugs
Symptoms: `DioException`, `SocketException`, `401`, `404`, `500`
1. Check `ApiConstants` — is the path correct?
2. Check `?academy=<id>` is included (multi-tenancy)
3. Check Dio response type: `dio.get<Map<String, dynamic>>()` — explicit generic required
4. Check `response.data!` vs `response.data` (null safety)
5. Check JWT interceptor: is it an auth endpoint path? Use `==` not `contains()`

### State / Provider bugs
Symptoms: widget not updating, stale data, `ProviderException`
1. Check if `autoDispose` is correct — family providers need it
2. Check `ref.invalidate(provider)` is called after mutations
3. Check `selectedAcademyIdProvider` is not null before using
4. For `StateNotifier`: verify `state = AsyncValue.data(...)` is set after async ops
5. Check `overrideWith((ref) =>` — NOT `overrideWith(() =>` in tests

### Widget / Rendering bugs
Symptoms: `RenderFlex overflow`, `Null check operator`, widget not found
1. Run `flutter analyze` — often catches the issue
2. Check `if (data == null)` guards before accessing nested properties
3. For overflow: add `Expanded`, `Flexible`, or `SingleChildScrollView`
4. For "widget not found in tests": check Key names, use `findsWidgets` not `findsOneWidget` when text appears multiple times

### Navigation bugs
Symptoms: `GoException`, wrong screen shown, back button issues
1. Check route path in `app_router.dart` — paths are exact
2. Nested routes: child path is relative (`:id`, not `/{feature}/:id`)
3. Shell routes: must be inside `ShellRoute` for bottom nav to show
4. Auth redirect: `isAuthenticatedProvider` must be invalidated after login (`ref.invalidate(isAuthenticatedProvider)`)

### Type / Null safety bugs
Symptoms: `Null check operator used on null value`, `type 'Null' is not subtype of...`
1. Check `fromJson` — use `as int?` then `?? defaultValue` pattern
2. Check Dio response: `response.data as Map<String, dynamic>` → use `response.data!` instead
3. Sealed class `ApiException` cannot be instantiated — use subclasses

## Step 3 — Fix approach
1. Fix the minimal change — do not refactor surrounding code
2. Verify fix with `flutter analyze`
3. Run the specific test file: `flutter test test/features/{feature}/`
4. If test doesn't exist, manually verify the fix makes sense

## Step 4 — Common FlowRoll-specific bugs

| Symptom | Likely cause | Fix |
|---|---|---|
| Login 200 OK but nothing happens | `isAuthenticatedProvider` not invalidated | `ref.invalidate(isAuthenticatedProvider)` before `context.go('/home')` |
| `OperationError` on Flutter Web | `flutter_secure_storage` Web Crypto | Check `kIsWeb` → use `SharedPreferences` |
| `inference_failure` analyzer warning | Missing Dio generic type | Change `dio.get(...)` to `dio.get<Map<String, dynamic>>(...)` |
| Tests: `overrideWith(() =>` type error | Riverpod 2 API | Change to `overrideWith((ref) =>` |
| `ApiException` can't be instantiated | It's a sealed class | Use `BadRequestException('msg')`, `UnauthorizedException()`, etc. |
| Belt chip text not found in test | `BeltChip` shows capitalized name | Find `'Blue'` not `'blue'` |
| CORS error on web dev | Backend missing `django-cors-headers` | Run Flutter with `--web-browser-flag="--disable-web-security"` for local dev only |

## Checklist
- [ ] Read full stack trace before any edit
- [ ] `flutter analyze` run first
- [ ] Minimal fix only — no surrounding refactors
- [ ] Test the specific file: `flutter test test/features/{feature}/`
- [ ] `flutter analyze` clean after fix

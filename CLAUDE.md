# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project in One Paragraph
FlowRoll is a BJJ (Brazilian Jiu-Jitsu) academy management SaaS. Academy owners manage athletes, schedule classes, track attendance (QR check-in + drop-ins), run live matches with real-time scoring, manage tatami matchups with countdown timers, and browse a techniques curriculum. The backend is a Django REST API with JWT auth and multi-tenant isolation via `?academy=<id>` query param.

## Environment Setup
```bash
cp .env.example .env   # set API_BASE_URL=http://localhost:8000
flutter pub get        # or: make setup
```
The `.env` file is injected at compile-time via `--dart-define-from-file=.env` (see Makefile targets).

## Commands
```bash
make dev              # Run on Chrome (hot reload, uses .env)
make dev-android      # Run on first connected Android device
make dev-web          # Web server on port 8090
make analyze          # flutter analyze
make lint             # format-check + analyze
make format           # dart format lib/ test/
make test             # All tests
make test-coverage    # Tests + coverage report → coverage/lcov.info
make clean            # Remove build artifacts + coverage/
```

Run a single test file:
```bash
flutter test test/features/athletes/athletes_list_screen_test.dart
```

## Tech Stack (actual — no code generation)
- Flutter 3.x + Dart, SDK ≥3.3.0
- State: **flutter_riverpod 2.x** — `StateNotifierProvider`, `FutureProvider.autoDispose.family`, plain `Provider`
- Navigation: **go_router 13** with one `ShellRoute` (bottom nav) + nested `GoRoute`s
- HTTP: **Dio 5** + custom `JwtInterceptor` (auto-refresh on 401, 10s timeout)
- Models: **plain Dart classes** with manual `fromJson`/`toJson` — NO freezed, NO json_serializable
- Config: `String.fromEnvironment('API_BASE_URL')` via `--dart-define-from-file=.env`
- Tests: **mocktail** mocks, `pumpApp()` / `pumpAppWithRouter()` helpers in `test/helpers/`

## Architecture (strict — one pattern everywhere)
```
lib/features/{feature}/
  data/     → {feature}_repository.dart   (Dio calls, ApiException wrapping)
  domain/   → {feature}_provider.dart     (Riverpod providers + Filter classes)
  presentation/
    screens/ → {feature}_screen.dart
    widgets/ → feature-scoped reusables
```
Shared: `lib/shared/models/` (data classes) · `lib/shared/widgets/` (ErrorView, EmptyView, ShimmerList, GlassCard, Tappable, BeltBadge, AppSearchBar)

## Core Infrastructure Files
- Router & guards: `lib/core/router/`
- API base URL, endpoint constants: `lib/core/api/api_constants.dart`
- Dio setup + JWT interceptor: `lib/core/api/dio_client.dart`
- Auth state (login, token refresh, logout): `lib/core/auth/auth_provider.dart`
- Theme tokens: `lib/core/theme/` — `AppColors`, `AppTextStyles`, `AppStrings`
- Bottom nav shell: `lib/shared/widgets/main_shell.dart`
- Test helpers: `test/helpers/pump_app.dart`, `fake_repositories.dart`, `test_data.dart`

## Coding Rules (non-negotiable)
- Colors: `AppColors.*` only — never raw `Color(0x…)` in screens
- Text styles: `AppTextStyles.*()` only — never raw `TextStyle()` in screens
- Strings: `AppStrings.*` for user-visible labels — never hardcoded
- Every screen needs all 4 states: `loading` → `ShimmerList(count:)`, `error` → `ErrorView(message:, onRetry:)`, `empty` → `EmptyView(icon:, message:)`, `data`
- Every interactive widget needs a `Key` for testability
- Multi-tenancy: list endpoints require `academyId` from `selectedAcademyIdProvider`; wrap calls in `if (academyId == null) return empty`
- `flutter analyze` must be clean before any task is done

## Route Map
| Path | Screen |
|---|---|
| `/splash` | SplashScreen |
| `/login` | LoginScreen |
| `/select-academy` | AcademySelectorScreen |
| `/home` | ClassesListScreen (shell root) |
| `/home/class/:id` | ClassDetailScreen |
| `/home/class/:id/qr` | QrGeneratorScreen |
| `/athletes` | AthletesListScreen |
| `/athletes/:id` | AthleteDetailScreen |
| `/athletes/new` | AthleteFormScreen |
| `/athletes/:id/edit` | AthleteFormScreen(athleteId:) |
| `/matches` | MatchesListScreen |
| `/matches/:id` | MatchDetailScreen |
| `/matches/:id/live` | LiveMatchScreen |
| `/tatami` | MatchupsScreen |
| `/tatami/timers` | TimerPresetsScreen |
| `/tatami/timers/:id/session` | TimerSessionScreen |
| `/tatami/weights` | WeightClassesScreen |
| `/techniques` | TechniquesCurriculumScreen |
| `/techniques/:id` | TechniqueDetailScreen |
| `/drop-ins` | DropInsScreen |
| `/qr-scan` | QrScannerScreen |

## API Endpoints (ApiConstants)
Auth: `/api/auth/token/` · `/api/auth/token/refresh/`
Academies: `/api/academies/`
Athletes: `/api/athletes/`
Attendance: `/api/attendance/classes/` · `manual_checkin/` · `qr_checkin/` · `/api/attendance/drop-ins/`
Matches: `/api/matches/`
Tatami: `/api/tatami/matchups/` · `pair_athletes/` · `timer-presets/` · `timer-sessions/` · `weight-classes/`
Techniques: `/api/techniques/belts/` · `categories/` · `techniques/` · `variations/`

## Active Skills — load when triggered
| Say this | Skill |
|---|---|
| "create a screen" | `.claude/skills/new_screen/SKILL.md` |
| "add a feature" | `.claude/skills/new_feature/SKILL.md` |
| "connect API endpoint" | `.claude/skills/api_integration/SKILL.md` |
| "write tests" | `.claude/skills/testing/SKILL.md` |
| "fix a bug" | `.claude/skills/debugging/SKILL.md` |
| "optimize performance" | `.claude/skills/performance/SKILL.md` |
| "create a widget" | `.claude/skills/new_widget/SKILL.md` |

## Do NOT read unless asked
- `build/` · `.dart_tool/` — generated artifacts
- `coverage/` — test output
- `assets/fonts/` · `assets/images/` — binary
- `*.g.dart` · `*.freezed.dart` · `*.mocks.dart` — generated (none exist currently)
- `README.md` · `ARCHITECTURE.md` · `CONTRIBUTING.md` · `DEPLOYMENT.md` — human docs
- `pubspec.lock` — dependency resolution artifact

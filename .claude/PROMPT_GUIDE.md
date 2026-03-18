# FlowRoll — Claude Prompt Cheatsheet

> Read this. Not Claude. These are your prompting patterns for getting fast, correct output.

---

## General Rules
1. **Reference exact file paths** — `lib/features/matches/...` not "the matches screen"
2. **Specify the API endpoint** by path, not description — `/api/attendance/classes/manual_checkin/`
3. **Batch related changes** in one prompt — don't send one change per message
4. **Start new features with /clear** — never carry context from a different domain
5. **End complex prompts with** "run flutter analyze when done"
6. **Specify `academy owner only` or `all roles`** when asking about access control

---

## Screen & Feature Creation

| ❌ Vague (expensive) | ✅ Precise (fast) |
|---|---|
| "Create a screen to show athletes" | "Create screen: `AthletesListScreen` already exists at `lib/features/athletes/presentation/screens/athletes_list_screen.dart`. Add a search bar that filters by name using `currentAcademyAthletesProvider(search)`." |
| "Add matches history" | "Create screen: `MatchHistoryScreen` in `lib/features/matches/presentation/screens/`. Shows finished matches only (filter `isFinished: true`). Reads from `matchesProvider` with academy filter. Route: `/matches/history`." |
| "Add the nutrition feature" | "Scaffold feature: `nutrition`. Model: `NutritionPlan(id, athleteId, calories, notes)`. Endpoints: GET/POST `/api/nutrition/plans/?academy=<id>`. List screen only for MVP. Academy owner can create/delete, athletes read-only." |

---

## API Integration

| ❌ Vague | ✅ Precise |
|---|---|
| "Connect the check-in endpoint" | "Connect: `POST /api/attendance/classes/qr_checkin/` body `{qr_token: string}`. Add `qrCheckIn({required String token})` to `AttendanceRepository`. On success: close scanner, show green SnackBar 'Checked in!'. On 400: show 'Invalid QR code'. Already have: `QrScannerScreen`, `ApiConstants.qrCheckinPath`." |
| "Make timer start/stop work" | "Wire `TimerSessionScreen` to API. Start: `POST /api/tatami/timer-sessions/` body `{preset: presetId}`. Store returned `id`. Pause: `POST /api/tatami/timer-sessions/{id}/pause/`. Resume: `POST /api/tatami/timer-sessions/{id}/resume/`. Finish: `POST /api/tatami/timer-sessions/{id}/finish/`. Update `TimerSessionNotifier` in `lib/features/tatami/domain/tatami_provider.dart`." |

---

## Bug Fixing

| ❌ Vague | ✅ Precise |
|---|---|
| "The app is broken" | "Bug: `AthletesListScreen` crashes with `RangeError: index out of range` when list is empty. File: `lib/features/athletes/presentation/screens/athletes_list_screen.dart` ~line 97. Expected: show `EmptyView`. Actual: crash on `athletes[0]`." |
| "Fix the login" | "Bug: after successful login (200 OK from `/api/auth/token/`), router stays on `/login`. File: `lib/features/auth/presentation/screens/login_screen.dart`. The `isAuthenticatedProvider` is not invalidated after storing tokens. Fix: add `ref.invalidate(isAuthenticatedProvider)` before `context.go('/home')`." |
| "Tests are failing" | "Fix failing test in `test/features/matches/live_match_screen_test.dart`. Error: `'Finish' not found`. Root cause: button label is `AppStrings.finishMatch = 'Finish Match'` not `'Finish'`. Change `find.text('Finish')` to `find.text('Finish Match')` in that file." |

---

## Tests

| ❌ Vague | ✅ Precise |
|---|---|
| "Write tests for the app" | "Write widget tests for `ClassDetailScreen` (`lib/features/attendance/presentation/screens/class_detail_screen.dart`). Cover: (1) shows class title, (2) shows attendance count, (3) tapping Manual Check-In opens sheet, (4) submitting form calls `mockRepo.manualCheckIn(athleteId:, trainingClassId:)`, (5) API error shows SnackBar. Use `test/helpers/` infrastructure." |
| "Test the form" | "Add test: `AthleteFormScreen` create mode — entering non-numeric userId shows 'Invalid user ID' error. File: `test/features/athletes/athlete_form_screen_test.dart`. Add to existing 'create mode' group." |

---

## Refactoring

| ❌ Vague | ✅ Precise |
|---|---|
| "Clean up the code" | "Extract from `live_match_screen.dart` (483 lines): (1) `_ScorePanel` widget → `lib/features/matches/presentation/widgets/score_panel.dart`, (2) `_EventTimeline` widget → `event_timeline.dart`. Keep all business logic in `LiveMatchNotifier`. Do not change any behavior." |
| "Optimize the list" | "Add `itemExtent: 88` to the `ListView.builder` in `AthletesListScreen` (all `AthleteCard` items are fixed 88px height). File: `lib/features/athletes/presentation/screens/athletes_list_screen.dart` ~line 110." |

---

## New Widgets

| ❌ Vague | ✅ Precise |
|---|---|
| "Add a card for matches" | "Create widget `MatchCard` in `lib/features/matches/presentation/widgets/match_card.dart`. Props: `Match match`, `VoidCallback? onTap`. Shows: athlete_a name (left), score (center), athlete_b name (right), `StatusBadge` if `isFinished`. Tappable navigates to `/matches/{match.id}`." |

---

## Workflow Shortcuts

```bash
# Analyze before committing
make analyze     # or: flutter analyze

# Run specific test file fast
flutter test test/features/matches/live_match_screen_test.dart

# Run all tests with coverage
make test-coverage   # or: flutter test --coverage

# Format before PR
dart format lib/ test/

# Build for testing on device
make build-apk   # or: flutter build apk --debug
```

---

## What Claude Knows By Default (from CLAUDE.md)
- Full route map — no need to describe navigation
- All API endpoint paths — reference by path
- All shared widgets — reference by name (`GlassCard`, `ErrorView`, `ShimmerList`)
- Architecture pattern — no need to explain where files go
- Theme system — `AppColors`, `AppTextStyles`, `AppStrings` are always used

## What Claude Does NOT Know Without Context
- Business logic / rules not in code (e.g. "a match can only be created if academy has ≥2 athletes")
- Backend validation rules
- Which features are in progress or blocked
- Your personal preference for code style beyond what's enforced

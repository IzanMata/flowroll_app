# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Security
- LogInterceptor disabled in release builds — tokens no longer printed to device log
- `usesCleartextTraffic` set to `false` on Android
- iOS `NSAllowsArbitraryLoads` replaced with localhost-only HTTP exception
- JWT token refresh endpoint uses exact path matching (prevents path-traversal bypass)
- Token refresh call has explicit 10s timeout to prevent indefinite hang
- `API_BASE_URL` injected via compile-time `--dart-define` instead of hardcoded string

### Fixed
- `MatchupsFilter` equality now includes `matchFormat` and `weightClass` fields
- Timer notifier `_roundDurationSeconds` is now private
- Dead `TimerSessionExtension` removed
- `presetsPage.results.first` crash replaced with null-safe `firstOrNull`

---

## [1.0.0] — 2024-01-01

### Added

#### Authentication
- JWT login with `username` + `password`
- Automatic token refresh on 401 with request queue
- Secure token storage via Flutter Secure Storage
- Auth guard on all protected routes (redirect to `/login`)

#### Academies
- Multi-academy selector screen
- Academy stored in provider, scopes all subsequent data fetches

#### Athletes
- List with search and belt filter (white → coral)
- Detail screen with full profile
- Create / edit form (User ID, belt, role, stripes)
- Roles: Student / Professor

#### Attendance
- Classes list by academy
- Class detail: attendance count, capacity, scheduled date/time
- Manual check-in (by Athlete ID)
- QR code generation for class check-in
- QR scanner for check-in (camera + torch toggle)
- Drop-ins management

#### Matches
- Matches list by academy
- Match detail screen
- Live match screen with score tracking and timer

#### Tatami
- Matchups list by academy with status badges
- Pair athletes form (comma-separated IDs, Tournament / Survival format)
- Timer presets list
- Timer session with local countdown, pause/resume/finish
- Weight classes list

#### Techniques
- Curriculum screen organized by belt and category
- Technique detail with description and variations

#### Core Infrastructure
- Dio HTTP client with 15s connect / 30s receive timeouts
- JWT interceptor with pending request queue
- GoRouter with shell routes (bottom navigation)
- Dark theme with custom color palette
- Google Fonts (Bebas Neue for display text)
- Shimmer loading states
- Error views with retry action
- Empty state views with call-to-action
- Glass card design system
- Belt badge with color + stripe visualization
- Status badges for match and matchup states
- Web platform support

[Unreleased]: https://github.com/your-org/flowroll_app/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/your-org/flowroll_app/releases/tag/v1.0.0

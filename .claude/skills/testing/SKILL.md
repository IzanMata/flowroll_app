---
name: testing
triggers: ["write tests", "add tests", "test this", "write widget tests"]
description: Protocol for writing widget tests in FlowRoll
---

# Testing Protocol

## Test infrastructure (already exists — use it)
```
test/
  helpers/
    pump_app.dart        → pumpApp(), pumpAppWithRouter() extensions
    fake_repositories.dart → Mock*Repository classes + stub extension methods
    test_data.dart       → fake*() factory functions for all models
```

## Widget test structure
**File location:** `test/features/{feature}/{screen}_test.dart`

```dart
import 'package:flowroll_app/core/auth/auth_provider.dart';
import 'package:flowroll_app/features/{feature}/data/{feature}_repository.dart';
import 'package:flowroll_app/features/{feature}/domain/{feature}_provider.dart';
import 'package:flowroll_app/features/{feature}/presentation/screens/{screen}.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_repositories.dart';
import '../../helpers/pump_app.dart';
import '../../helpers/test_data.dart';

void main() {
  late Mock{Feature}Repository mockRepo;

  setUp(() {
    mockRepo = Mock{Feature}Repository();
    registerFallbacks();
  });

  List<Override> _overrides({int? academyId = 1}) => [
        {feature}RepositoryProvider.overrideWithValue(mockRepo),
        selectedAcademyIdProvider.overrideWith((ref) => _FixedAcademyNotifier(academyId)),
      ];

  group('{Screen} — rendering', () {
    testWidgets('shows {item} after load', (tester) async {
      mockRepo.stub{List}(fake{Model}sPage([fake{Model}()]));

      await tester.pumpApp(const {Screen}(), overrides: _overrides());
      await tester.pumpAndSettle();

      expect(find.text('expected text'), findsOneWidget);
    });

    testWidgets('shows empty view when no data', (tester) async {
      mockRepo.stub{List}(emptyPage());
      await tester.pumpApp(const {Screen}(), overrides: _overrides());
      await tester.pumpAndSettle();
      expect(find.textContaining('No '), findsOneWidget);
    });

    testWidgets('shows error view on fetch failure', (tester) async {
      when(() => mockRepo.{method}(...)).thenThrow(Exception('error'));
      await tester.pumpApp(const {Screen}(), overrides: _overrides());
      await tester.pumpAndSettle();
      expect(find.textContaining('Exception'), findsOneWidget);
    });
  });

  group('{Screen} — interactions', () {
    testWidgets('tapping X does Y', (tester) async {
      mockRepo.stub{List}(fake{Model}sPage([fake{Model}()]));
      await tester.pumpApp(const {Screen}(), overrides: _overrides());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('{feature}_{action}_button')));
      await tester.pumpAndSettle();

      // assert navigation, API call, or UI change
      verify(() => mockRepo.{method}(...)).called(1);
    });
  });
}

class _FixedAcademyNotifier extends SelectedAcademyNotifier {
  _FixedAcademyNotifier(this._id) : super() { state = _id; }
  final int? _id;
}
```

## Finding widgets (priority order)
1. **Key** (most stable): `find.byKey(const Key('athletes_create_fab'))`
2. **Semantic label**: `find.bySemanticsLabel('Create athlete')`
3. **Exact text**: `find.text('Add Event')`
4. **Text containing**: `find.textContaining('No athletes')`
5. **Icon**: `find.byIcon(Icons.add_rounded)`
6. **Widget type** (last resort): `find.byType(FloatingActionButton)`

## Key assertions
```dart
// Visibility
expect(find.text('x'), findsOneWidget);      // exactly 1
expect(find.text('x'), findsWidgets);         // 1 or more (use when text appears in multiple widgets)
expect(find.text('x'), findsNothing);         // absent
expect(find.text('x'), findsNWidgets(2));     // exactly 2

// API call verification
verify(() => mockRepo.createAthlete(
  userId: 42,
  academyId: any(named: 'academyId'),
  belt: any(named: 'belt'),
)).called(1);
verifyNever(() => mockRepo.deleteAthlete(any()));

// Widget state
final button = tester.widget<ElevatedButton>(find.byKey(...));
expect(button.onPressed, isNull); // disabled
```

## StateNotifier fakes
When a screen reads from a StateNotifier (not FutureProvider), create a fake:
```dart
class _Fake{Name}Notifier extends {Name}Notifier {
  _Fake{Name}Notifier(this._initial, Repo repo) : super(repo, 1) {
    state = AsyncValue.data(_initial);
  }
  final {Model} _initial;

  @override
  Future<void> load{Model}(int id) async {
    state = AsyncValue.data(_initial);
  }
}
// Override: {name}Provider.overrideWith((ref) => _Fake{Name}Notifier(data, mockRepo))
```

## Common gotchas
- `overrideWith` requires `(ref) =>`, NOT `() =>` — Riverpod 2 StateNotifier API
- `ApiException` is sealed — use subclasses: `UnauthorizedException()`, `BadRequestException('msg')`
- `BeltChip` displays capitalized enum name (`'Blue'`), NOT `belt.value` (`'blue'`)
- When text appears in multiple widgets (e.g. athlete name in score + winner badge), use `findsWidgets` not `findsOneWidget`
- Bottom sheet content: `pumpAndSettle()` after `tap()` to let sheet animate

## Running tests
```bash
flutter test                                          # all tests
flutter test test/features/{feature}/                # one feature
flutter test test/features/{feature}/{screen}_test.dart  # one file
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```

## Checklist
- [ ] Imports at top of file (no imports after class definitions)
- [ ] `registerFallbacks()` called in `setUp`
- [ ] All `overrideWith` use `(ref) =>` not `() =>`
- [ ] Every test group covers: rendering, empty state, error state, interactions
- [ ] `pumpAndSettle()` after every `tap()` that triggers async work
- [ ] `flutter test` passes with 0 failures

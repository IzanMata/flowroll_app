---
name: performance
triggers: ["optimize performance", "performance issue", "app is slow", "jank", "too many rebuilds"]
description: Protocol for diagnosing and fixing Flutter performance issues in FlowRoll
---

# Performance Protocol

## Step 1 — Measure before optimizing
```bash
flutter run --profile
# Then open DevTools: http://127.0.0.1:{port}
```
Never optimize without data. Check:
- Performance overlay: red bars = jank frames (>16ms)
- Widget rebuild tracker: unnecessary rebuilds show as highlights
- Memory: watch for leaks in long sessions

## Step 2 — Common FlowRoll performance issues

### Excessive rebuilds (most common)
**Symptom:** Whole screen rebuilds on small state change

Fixes:
```dart
// 1. Use select() to watch only part of state
final count = ref.watch(matchProvider.select((m) => m?.scoreA));

// 2. const constructors on static widgets
const Text('Score'),   // not Text('Score')
const SizedBox(height: 12),

// 3. Extract large widgets into separate ConsumerWidget classes
// instead of giant build() methods

// 4. Use Consumer/ConsumerWidget surgically
Consumer(
  builder: (context, ref, child) {
    final score = ref.watch(scoreProvider);
    return Text('$score');
  },
),
```

### ListView performance
```dart
// 1. Use ListView.builder (lazy), not ListView with children: [...]
ListView.builder(
  itemCount: items.length,
  itemExtent: 80,   // set when all items same height — enables O(1) scroll
  itemBuilder: (_, i) => ItemCard(item: items[i]),
)

// 2. Add const to identical separators
separatorBuilder: (_, __) => const SizedBox(height: 12),
```

### Image loading
```dart
// Already have cached_network_image — ensure it's used:
CachedNetworkImage(
  imageUrl: url,
  placeholder: (_, __) => const ShimmerBox(height: 48, width: 48),
  errorWidget: (_, __, ___) => const Icon(Icons.person_rounded),
)
// Never use Image.network() directly
```

### Provider over-watching
```dart
// BAD — whole widget rebuilds when any part of filter changes
final filter = ref.watch(athletesFilterProvider);

// GOOD — only rebuild when academyId changes
final academyId = ref.watch(selectedAcademyIdProvider);
```

### Timer / animation leaks
```dart
// Always dispose in State:
@override
void dispose() {
  _timer?.cancel();
  _animController.dispose();
  super.dispose();
}
```

## Step 3 — Shimmer loading performance
`ShimmerList` and `ShimmerBox` use `shimmer` package which is hardware-accelerated.
Do NOT use `Opacity` widget for shimmer effects — it forces rasterization layer.

## Step 4 — Build mode checks
```bash
flutter build apk --release --analyze-size   # APK size analysis
flutter build web --release                   # Tree shaken web build
dart analyze --fatal-infos                   # Catch performance-related hints
```

## Step 5 — Check for anti-patterns in screen files
Run through these for any screen >200 lines:
- [ ] `const` on all static widgets
- [ ] `itemExtent` on same-height ListViews
- [ ] No `setState` that rebuilds more than necessary
- [ ] `ref.watch` only for values actually used in build
- [ ] Heavy computation not done in `build()` — move to provider
- [ ] Infinite scroll: load next page only when near bottom (80%+ scrolled)

## Checklist
- [ ] Profile mode measurement done before any change
- [ ] DevTools Widget Inspector checked for unnecessary rebuilds
- [ ] `const` added to static widgets
- [ ] `itemExtent` set for fixed-height lists
- [ ] `select()` used for partial state watching
- [ ] No `Image.network()` — `CachedNetworkImage` only
- [ ] Timers and controllers disposed in `dispose()`
- [ ] `flutter analyze` clean after changes

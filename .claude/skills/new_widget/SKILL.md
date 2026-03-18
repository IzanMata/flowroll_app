---
name: new_widget
triggers: ["create a widget", "new widget", "extract widget", "add a widget"]
description: Protocol for creating reusable widgets in FlowRoll
---

# New Widget Protocol

## Step 1 — Decide where it lives
- **Global reusable** (used by 2+ features): `lib/shared/widgets/{name}.dart`
- **Feature-specific**: `lib/features/{feature}/presentation/widgets/{name}.dart`
- **Screen-private** (used only in one screen): private class at bottom of screen file (`class _PrivateName`)

## Step 2 — Choose the right base class

| Use case | Class |
|---|---|
| No internal state, no providers | `StatelessWidget` |
| Internal state only (animation, form, toggle) | `StatefulWidget` |
| Reads providers, no internal state | `ConsumerWidget` |
| Reads providers + internal state | `ConsumerStatefulWidget` |

## Step 3 — Widget template

### Stateless (most common for shared widgets)
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// {Description of what this widget does and when to use it}.
///
/// Required: [param1], [param2]
/// Optional: [optionalParam]
class {Name}Widget extends StatelessWidget {
  const {Name}Widget({
    super.key,
    required this.param1,
    this.optionalParam,
    this.onTap,
  });

  final String param1;
  final String? optionalParam;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Use AppColors, AppTextStyles — never hardcoded
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Text(param1, style: AppTextStyles.bodyMedium()),
      ),
    );
  }
}
```

### ConsumerWidget (reads Riverpod state)
```dart
class {Name}Widget extends ConsumerWidget {
  const {Name}Widget({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(someProvider(id));
    return data.when(
      loading: () => const ShimmerBox(height: 48),
      error: (e, _) => const SizedBox.shrink(),
      data: (value) => Text(value.name),
    );
  }
}
```

## Step 4 — Non-negotiable rules
- **`super.key`** always in constructor — enables widget testing
- **Colors**: `AppColors.*` only — never `Color(0xFF...)` or `Colors.blue`
- **Text styles**: `AppTextStyles.*()` — never raw `TextStyle(...)`
- **Strings**: `AppStrings.*` for user-visible text — never hardcoded in widgets
- **`const` constructible** if all fields are final and no mutable defaults
- **Theme from context**: derive dynamic values from `Theme.of(context)` if needed

## Step 5 — Naming and Key conventions
```dart
// Widget Key pattern: '{feature}_{descriptor}'
const Key('athletes_belt_badge')
const Key('match_score_panel')
const Key('timer_start_button')
```

## Step 6 — Existing shared widgets to reuse first
Before creating, check if one of these fits:
| Widget | Use for |
|---|---|
| `GlassCard` | Card/panel containers with glass-morphism look |
| `ErrorView` | Error state with optional retry button |
| `EmptyView` | Empty state with icon + message + optional action |
| `ShimmerList(count:)` | Loading state for lists |
| `ShimmerBox(height:, width:)` | Loading state for single items |
| `AppSearchBar` | Search input with debounce |
| `BeltBadge` | Display belt color + stripes |
| `BeltChip` | Selectable belt filter chip |
| `Tappable` | GestureDetector with scale animation feedback |
| `StatusBadge` | Colored label badge (FINISHED, LIVE, etc.) |

## Checklist
- [ ] Correct location (shared vs feature-specific vs private)
- [ ] `super.key` in constructor
- [ ] `const` constructible (if stateless)
- [ ] Only `AppColors.*`, `AppTextStyles.*`, `AppStrings.*` — no hardcoded values
- [ ] Dartdoc comment explaining what it does and required params
- [ ] All interactive sub-widgets have `Key` values
- [ ] Checked existing shared widgets — not reinventing one
- [ ] `flutter analyze` clean

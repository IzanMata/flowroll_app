---
name: new_screen
triggers: ["create a screen", "add a screen", "new screen"]
description: Protocol for creating a new Flutter screen in FlowRoll
---

# New Screen Protocol

## Step 1 — Clarify before writing
Ask (or infer from context):
- Feature name (existing or new?)
- Data source (which provider / repository method?)
- Route path and params
- Does it need `academyId` from `selectedAcademyIdProvider`?

## Step 2 — Create the file
**Path:** `lib/features/{feature}/presentation/screens/{name}_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/app_shimmer.dart';
// import relevant provider

class {Name}Screen extends ConsumerWidget {
  const {Name}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch({provider});

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.{title}, style: AppTextStyles.titleLarge()),
      ),
      body: dataAsync.when(
        loading: () => const ShimmerList(count: 5),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate({provider}),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              icon: Icons.{icon}_rounded,
              message: AppStrings.{emptyMessage},
            );
          }
          return ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => {ItemCard}(item: items[i]),
          );
        },
      ),
    );
  }
}
```

## Step 3 — Register the route
In `lib/core/router/app_router.dart`, add inside the correct parent:
```dart
GoRoute(
  path: '/{feature}',          // or nested: path: ':id'
  builder: (_, state) => {Name}Screen(
    // pass path params: int.parse(state.pathParameters['id']!)
  ),
),
```
Nested screens go inside `routes:` of their parent `GoRoute`.

## Step 4 — Multi-tenancy check
If the screen loads data scoped to an academy:
```dart
final academyId = ref.watch(selectedAcademyIdProvider);
if (academyId == null) {
  return const EmptyView(message: 'Select an academy');
}
```

## Step 5 — Key all interactive elements
```dart
ElevatedButton(
  key: const Key('{feature}_{action}_button'),
  ...
)
```
Pattern: `{feature}_{widget}_{action}` (e.g. `athletes_create_fab`, `match_finish_button`)

## Checklist
- [ ] File in correct `presentation/screens/` path
- [ ] Uses `ConsumerWidget` or `ConsumerStatefulWidget`
- [ ] All 4 states: loading (ShimmerList), error (ErrorView+onRetry), empty (EmptyView), data
- [ ] Colors from `AppColors.*` only
- [ ] Strings from `AppStrings.*` only
- [ ] Route added to `app_router.dart`
- [ ] Keys on all interactive widgets
- [ ] `flutter analyze` clean

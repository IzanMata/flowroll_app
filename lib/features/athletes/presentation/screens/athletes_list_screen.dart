import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/athlete.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/belt_badge.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/tappable.dart';
import '../../domain/athletes_provider.dart';

class AthletesListScreen extends ConsumerStatefulWidget {
  const AthletesListScreen({super.key});

  @override
  ConsumerState<AthletesListScreen> createState() => _AthletesListScreenState();
}

class _AthletesListScreenState extends ConsumerState<AthletesListScreen> {
  String _search = '';
  BeltEnum? _beltFilter;

  @override
  Widget build(BuildContext context) {
    final academyId = ref.watch(selectedAcademyIdProvider);
    if (academyId == null) {
      return _NoAcademyView();
    }

    final filter = AthletesFilter(
      academyId: academyId,
      search: _search.isEmpty ? null : _search,
    );
    final athletesAsync = ref.watch(athletesProvider(filter));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          AppStrings.athletesList,
          style: AppTextStyles.titleLarge(
            color: isDark ? AppColors.onBackground : AppColors.lightOnBackground,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                Icons.person_add_rounded,
                color: isDark ? AppColors.primary : AppColors.primaryLight,
              ),
              onPressed: () => context.push('/athletes/new'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AppSearchBar(
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _beltFilter == null,
                  onTap: () => setState(() => _beltFilter = null),
                ),
                const SizedBox(width: 8),
                ...BeltEnum.values.map((belt) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: BeltChip(
                        belt: belt,
                        selected: _beltFilter == belt,
                        onTap: () => setState(
                          () => _beltFilter = _beltFilter == belt ? null : belt,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: athletesAsync.when(
              loading: () => const ShimmerList(),
              error: (e, _) => ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(athletesProvider(filter)),
              ),
              data: (page) {
                var athletes = page.results;
                if (_beltFilter != null) {
                  athletes = athletes.where((a) => a.belt == _beltFilter).toList();
                }
                if (athletes.isEmpty) {
                  return EmptyView(
                    icon: Icons.people_rounded,
                    message: AppStrings.noAthletes,
                    action: () => context.push('/athletes/new'),
                    actionLabel: AppStrings.addAthlete,
                  );
                }
                return RefreshIndicator(
                  color: isDark ? AppColors.primary : AppColors.primaryLight,
                  backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
                  onRefresh: () async => ref.invalidate(athletesProvider(filter)),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: athletes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _AthleteCard(athlete: athletes[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AthleteCard extends StatelessWidget {
  const _AthleteCard({required this.athlete});

  final AthleteProfile athlete;

  Color _avatarColor(bool isDark) {
    if (athlete.belt == null) {
      return isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant;
    }
    return AppColors.beltColor(athlete.belt!.name).withValues(alpha: 0.2);
  }

  Color _avatarTextColor(bool isDark) {
    if (athlete.belt == null) {
      return isDark ? AppColors.muted : AppColors.lightMuted;
    }
    return AppColors.beltColor(athlete.belt!.name);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surface : AppColors.lightSurface;
    final border = isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder;
    final onBg = isDark ? AppColors.onBackground : AppColors.lightOnBackground;

    return Tappable(
      onTap: () => context.push('/athletes/${athlete.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Hero(
              tag: 'athlete-${athlete.id}',
              child: CircleAvatar(
                radius: 22,
                backgroundColor: _avatarColor(isDark),
                child: Text(
                  athlete.username.substring(0, 1).toUpperCase(),
                  style: AppTextStyles.titleSmall(color: _avatarTextColor(isDark)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(athlete.username, style: AppTextStyles.titleSmall(color: onBg)),
                  const SizedBox(height: 1),
                  Text(athlete.email, style: AppTextStyles.bodySmall()),
                  if (athlete.belt != null) ...[
                    const SizedBox(height: 6),
                    BeltBadge(
                      belt: athlete.belt!,
                      stripes: athlete.stripes ?? 0,
                      size: BeltBadgeSize.small,
                      showLabel: false,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (athlete.role != null)
                  _RoleBadge(
                    role: athlete.role!,
                    isDark: isDark,
                  ),
                const SizedBox(height: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.muted,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.isDark});

  final RoleEnum role;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isProfessor = role == RoleEnum.professor;
    final color = isProfessor ? AppColors.tertiary : AppColors.muted;
    final bg = isProfessor
        ? AppColors.tertiary.withValues(alpha: 0.12)
        : (isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isProfessor ? 'Professor' : 'Student',
        style: AppTextStyles.labelSmall(color: color),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primary : AppColors.primaryLight;
    final border = isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder;
    final bg = isDark ? AppColors.surfaceVariant : AppColors.lightSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.15) : bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primary : border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(
            color: selected ? primary : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

class _NoAcademyView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      body: EmptyView(
        icon: Icons.school_rounded,
        message: 'Select an academy to get started',
        action: () => context.push('/select-academy'),
        actionLabel: AppStrings.selectAcademy,
      ),
    );
  }
}

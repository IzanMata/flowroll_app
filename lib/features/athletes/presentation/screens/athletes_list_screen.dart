import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../shared/models/athlete.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/belt_badge.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/app_search_bar.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.athletesList, style: AppTextStyles.titleLarge()),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
            onPressed: () => context.push('/athletes/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: AppSearchBar(
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: 12),
          // Belt filter chips
          SizedBox(
            height: 40,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            () => _beltFilter = _beltFilter == belt ? null : belt),
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
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  onRefresh: () async => ref.invalidate(athletesProvider(filter)),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: athletes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
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

  @override
  Widget build(BuildContext context) {
    return Tappable(
      onTap: () => context.push('/athletes/${athlete.id}'),
      child: GlassCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surfaceVariant,
              child: Text(
                athlete.username.substring(0, 1).toUpperCase(),
                style: AppTextStyles.titleMedium(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(athlete.username, style: AppTextStyles.titleSmall()),
                  Text(athlete.email, style: AppTextStyles.bodySmall()),
                  const SizedBox(height: 6),
                  if (athlete.belt != null)
                    BeltBadge(
                      belt: athlete.belt!,
                      stripes: athlete.stripes ?? 0,
                      size: BeltBadgeSize.small,
                      showLabel: false,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (athlete.role != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: athlete.role == RoleEnum.professor
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      athlete.role == RoleEnum.professor ? 'Professor' : 'Student',
                      style: AppTextStyles.labelSmall(
                        color: athlete.role == RoleEnum.professor
                            ? AppColors.secondary
                            : AppColors.muted,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(
            color: selected ? AppColors.primary : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

class _NoAcademyView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: EmptyView(
        icon: Icons.school_rounded,
        message: 'Select an academy to get started',
        action: () => context.push('/select-academy'),
        actionLabel: AppStrings.selectAcademy,
      ),
    );
  }
}

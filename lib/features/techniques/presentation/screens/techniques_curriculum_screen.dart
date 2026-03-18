import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/athlete.dart';
import '../../../../shared/models/technique.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tappable.dart';
import '../../domain/techniques_provider.dart';

class TechniquesCurriculumScreen extends ConsumerStatefulWidget {
  const TechniquesCurriculumScreen({super.key});

  @override
  ConsumerState<TechniquesCurriculumScreen> createState() =>
      _TechniquesCurriculumScreenState();
}

class _TechniquesCurriculumScreenState
    extends ConsumerState<TechniquesCurriculumScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  String _search = '';

  static const _belts = [
    BeltEnum.white,
    BeltEnum.blue,
    BeltEnum.purple,
    BeltEnum.brown,
    BeltEnum.black,
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _belts.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.techniques, style: AppTextStyles.titleLarge()),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.labelMedium(color: AppColors.primary),
          unselectedLabelStyle: AppTextStyles.labelMedium(color: AppColors.muted),
          tabAlignment: TabAlignment.start,
          tabs: _belts.map((b) {
            final beltColor = AppColors.beltColor(b.value);
            return Tab(
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: beltColor,
                      shape: BoxShape.circle,
                      border: b == BeltEnum.white
                          ? Border.all(color: AppColors.surfaceBorder)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(b.name[0].toUpperCase() + b.name.substring(1)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: AppSearchBar(onChanged: (v) => setState(() => _search = v)),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: _belts.map((b) => _BeltTechniquesList(
                    belt: b,
                    search: _search.isEmpty ? null : _search,
                  )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BeltTechniquesList extends ConsumerWidget {
  const _BeltTechniquesList({required this.belt, this.search});

  final BeltEnum belt;
  final String? search;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = TechniquesFilter(search: search);
    final techniqueAsync = ref.watch(techniquesProvider(filter));

    return techniqueAsync.when(
      loading: () => const ShimmerList(count: 4),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(techniquesProvider(filter)),
      ),
      data: (page) {
        final filtered = page.results
            .where((t) => t.minBelt == belt.value)
            .toList();
        if (filtered.isEmpty) {
          return EmptyView(
            icon: Icons.school_rounded,
            message: 'No ${belt.name} belt techniques',
          );
        }
        return ListView.separated(
          padding: AppSpacing.screenPadding,
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _TechniqueCard(technique: filtered[i]),
        );
      },
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  const _TechniqueCard({required this.technique});

  final Technique technique;

  @override
  Widget build(BuildContext context) {
    final beltColor = AppColors.beltColor(technique.minBelt);

    return Tappable(
      onTap: () => context.push('/techniques/${technique.id}'),
      child: GlassCard(
        borderColor: beltColor.withValues(alpha: 0.3),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 56,
              decoration: BoxDecoration(
                color: beltColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: beltColor.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(technique.name, style: AppTextStyles.titleSmall()),
                  if (technique.categories.isNotEmpty)
                    Text(
                      technique.categories.map((c) => c.name).join(', '),
                      style: AppTextStyles.bodySmall(),
                    ),
                  if (technique.difficulty != null)
                    _DifficultyDots(difficulty: technique.difficulty!),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (technique.variations.isNotEmpty)
                  Text(
                    '${technique.variations.length} var.',
                    style: AppTextStyles.labelSmall(color: AppColors.muted),
                  ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyDots extends StatelessWidget {
  const _DifficultyDots({required this.difficulty});

  final int difficulty;

  @override
  Widget build(BuildContext context) {
    const max = 5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= max; i++)
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 2, top: 3),
            decoration: BoxDecoration(
              color: i <= difficulty ? AppColors.secondary : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

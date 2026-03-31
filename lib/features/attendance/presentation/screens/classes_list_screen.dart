import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/attendance.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/tappable.dart';
import '../../domain/attendance_provider.dart';

class ClassesListScreen extends ConsumerWidget {
  const ClassesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academyId = ref.watch(selectedAcademyIdProvider);
    final classesAsync = ref.watch(todaysClassesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColors.lightBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appName,
              style: AppTextStyles.titleLarge(
                color: isDark ? AppColors.onBackground : AppColors.lightOnBackground,
              ),
            ),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: AppTextStyles.labelMedium(color: AppColors.muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.school_outlined,
                color: isDark ? AppColors.muted : AppColors.lightMuted),
            onPressed: () => context.push('/select-academy'),
            tooltip: AppStrings.selectAcademy,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(Icons.qr_code_scanner_rounded,
                  color: isDark ? AppColors.primary : AppColors.primaryLight),
              onPressed: () => context.push('/qr-scan'),
              tooltip: AppStrings.scanQr,
            ),
          ),
        ],
      ),
      body: academyId == null
          ? EmptyView(
              icon: Icons.school_rounded,
              message: 'Select an academy to see classes',
              action: () => context.push('/select-academy'),
              actionLabel: AppStrings.selectAcademy,
            )
          : RefreshIndicator(
              color: isDark ? AppColors.primary : AppColors.primaryLight,
              backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
              onRefresh: () async => ref.invalidate(todaysClassesProvider),
              child: classesAsync.when(
                loading: () => const Column(
                  children: [
                    _StatsHeaderShimmer(),
                    Expanded(child: ShimmerList(count: 4)),
                  ],
                ),
                error: (e, _) => ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(todaysClassesProvider),
                ),
                data: (classes) {
                  final totalCheckins = classes.fold<int>(
                    0,
                    (sum, c) => sum + c.attendanceCount,
                  );
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: _StatsHeader(
                          classCount: classes.length,
                          totalCheckins: totalCheckins,
                        ),
                      ),
                      if (classes.isEmpty)
                        const SliverFillRemaining(
                          child: EmptyView(
                            icon: Icons.event_rounded,
                            message: AppStrings.noClasses,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          sliver: SliverList.separated(
                            itemCount: classes.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _ClassCard(trainingClass: classes[i]),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
      floatingActionButton: academyId != null
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/drop-ins'),
              icon: const Icon(Icons.group_add_rounded),
              label: const Text(AppStrings.dropIns),
            )
          : null,
    );
  }
}

// ─── Stats header ────────────────────────────────────────────────────────────

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.classCount, required this.totalCheckins});

  final int classCount;
  final int totalCheckins;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: "Today's classes",
              value: '$classCount',
              icon: Icons.calendar_today_rounded,
              color: isDark ? AppColors.primary : AppColors.primaryLight,
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Total check-ins',
              value: '$totalCheckins',
              icon: Icons.how_to_reg_rounded,
              color: AppColors.secondary,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppColors.surface : AppColors.lightSurface;
    final border = isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.statNumber(color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelMedium()),
        ],
      ),
    );
  }
}

class _StatsHeaderShimmer extends StatelessWidget {
  const _StatsHeaderShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surface : AppColors.lightSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: AppShimmer(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 96,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 96,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Class card ───────────────────────────────────────────────────────────────

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.trainingClass});

  final TrainingClass trainingClass;

  Color get _typeColor => switch (trainingClass.classType) {
        ClassTypeEnum.gi => AppColors.primary,
        ClassTypeEnum.nogi => AppColors.tertiary,
        ClassTypeEnum.openMat => AppColors.secondary,
        ClassTypeEnum.kids => AppColors.kidsOrange,
        ClassTypeEnum.competition => AppColors.competitionPink,
        null => AppColors.muted,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surface : AppColors.lightSurface;
    final border = isDark ? AppColors.surfaceBorder : AppColors.lightSurfaceBorder;
    final typeColor = _typeColor;
    final timeStr = DateFormat('h:mm a').format(trainingClass.scheduledAt);
    final duration = trainingClass.durationMinutes;

    return Tappable(
      onTap: () => context.push('/home/class/${trainingClass.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            // Left accent bar + time
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                border: Border(
                  right: BorderSide(color: border),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timeStr.split(' ')[0],
                    style: AppTextStyles.titleMedium(
                      color: isDark ? AppColors.onBackground : AppColors.lightOnBackground,
                    ),
                  ),
                  Text(
                    timeStr.split(' ')[1].toLowerCase(),
                    style: AppTextStyles.labelSmall(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            trainingClass.classType?.label ?? 'Class',
                            style: AppTextStyles.labelSmall(color: typeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trainingClass.title,
                      style: AppTextStyles.titleSmall(
                        color: isDark ? AppColors.onBackground : AppColors.lightOnBackground,
                      ),
                    ),
                    if (trainingClass.professorUsername.isNotEmpty ||
                        duration != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (trainingClass.professorUsername.isNotEmpty)
                            trainingClass.professorUsername,
                          if (duration != null) '${duration}min',
                        ].join('  ·  '),
                        style: AppTextStyles.bodySmall(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Check-in count
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Text(
                    '${trainingClass.attendanceCount}',
                    style: AppTextStyles.titleMedium(
                      color: isDark ? AppColors.primary : AppColors.primaryLight,
                    ),
                  ),
                  Text('in', style: AppTextStyles.labelSmall()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

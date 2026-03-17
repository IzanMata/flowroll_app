import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/attendance.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/tappable.dart';
import '../../domain/attendance_provider.dart';

class ClassesListScreen extends ConsumerWidget {
  const ClassesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academyId = ref.watch(selectedAcademyIdProvider);
    final classesAsync = ref.watch(todaysClassesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.appName, style: AppTextStyles.displaySmall(color: AppColors.primary)),
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: AppTextStyles.labelMedium(color: AppColors.muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.school_rounded, color: AppColors.muted),
            onPressed: () => context.push('/select-academy'),
            tooltip: AppStrings.selectAcademy,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
            onPressed: () => context.push('/qr-scan'),
            tooltip: AppStrings.scanQr,
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
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
              onRefresh: () async => ref.invalidate(todaysClassesProvider),
              child: classesAsync.when(
                loading: () => const ShimmerList(count: 4),
                error: (e, _) => ErrorView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(todaysClassesProvider),
                ),
                data: (classes) {
                  if (classes.isEmpty) {
                    return const EmptyView(
                      icon: Icons.event_rounded,
                      message: AppStrings.noClasses,
                    );
                  }
                  return ListView.separated(
                    padding: AppSpacing.screenPadding,
                    itemCount: classes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _ClassCard(trainingClass: classes[i]),
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

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.trainingClass});

  final TrainingClass trainingClass;

  Color get _typeColor => switch (trainingClass.classType) {
        ClassTypeEnum.gi => AppColors.primary,
        ClassTypeEnum.nogi => AppColors.secondary,
        ClassTypeEnum.openMat => AppColors.tertiary,
        ClassTypeEnum.kids => const Color(0xFFFF9800),
        ClassTypeEnum.competition => const Color(0xFFE91E63),
        null => AppColors.muted,
      };

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(trainingClass.scheduledAt);
    final duration = trainingClass.durationMinutes;

    return Tappable(
      onTap: () => context.push('/home/class/${trainingClass.id}'),
      child: GlassCard(
        child: Row(
          children: [
            // Time column
            SizedBox(
              width: 56,
              child: Column(
                children: [
                  Text(timeStr.split(' ')[0], style: AppTextStyles.titleMedium(color: AppColors.primary)),
                  Text(timeStr.split(' ')[1], style: AppTextStyles.labelSmall(color: AppColors.muted)),
                ],
              ),
            ),
            Container(width: 1, height: 48, color: AppColors.surfaceBorder),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: _typeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        trainingClass.classType?.label ?? 'Class',
                        style: AppTextStyles.labelSmall(color: _typeColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(trainingClass.title, style: AppTextStyles.titleSmall()),
                  Text(
                    trainingClass.professorUsername.isNotEmpty
                        ? '${trainingClass.professorUsername}${duration != null ? '  ·  ${duration}min' : ''}'
                        : duration != null ? '${duration}min' : '',
                    style: AppTextStyles.bodySmall(),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${trainingClass.attendanceCount}',
                    style: AppTextStyles.titleSmall(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 4),
                Text('checked in', style: AppTextStyles.labelSmall()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

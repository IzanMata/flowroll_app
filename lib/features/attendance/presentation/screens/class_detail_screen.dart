import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/attendance_provider.dart';

class ClassDetailScreen extends ConsumerWidget {
  const ClassDetailScreen({super.key, required this.classId});

  final int classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classAsync = ref.watch(trainingClassDetailProvider(classId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Class Details', style: AppTextStyles.titleLarge()),
      ),
      body: classAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (cls) => SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cls.title, style: AppTextStyles.titleLarge()),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, MMM d · h:mm a').format(cls.scheduledAt),
                      style: AppTextStyles.bodyMedium(color: AppColors.muted),
                    ),
                    if (cls.durationMinutes != null) ...[
                      const SizedBox(height: 4),
                      Text('${cls.durationMinutes} minutes',
                          style: AppTextStyles.bodySmall()),
                    ],
                    if (cls.notes != null && cls.notes!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(cls.notes!,
                          style: AppTextStyles.bodyMedium(color: AppColors.muted)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(
                            '${cls.attendanceCount}',
                            style: AppTextStyles.displaySmall(color: AppColors.primary),
                          ),
                          Text('Checked In', style: AppTextStyles.labelSmall()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (cls.maxCapacity != null)
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Text(
                              '${cls.maxCapacity}',
                              style: AppTextStyles.displaySmall(),
                            ),
                            Text('Capacity', style: AppTextStyles.labelSmall()),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Actions', style: AppTextStyles.titleSmall()),
              const SizedBox(height: 12),
              _ActionButton(
                icon: Icons.qr_code_2_rounded,
                label: AppStrings.generateQr,
                color: AppColors.primary,
                onTap: () => context.push('/home/class/$classId/qr'),
              ),
              const SizedBox(height: 10),
              _ActionButton(
                icon: Icons.how_to_reg_rounded,
                label: AppStrings.manualCheckIn,
                color: AppColors.tertiary,
                onTap: () => _showManualCheckIn(context, ref, cls.academy),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualCheckIn(BuildContext context, WidgetRef ref, int academyId) {
    final athleteIdCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.manualCheckIn, style: AppTextStyles.titleLarge()),
            const SizedBox(height: 16),
            TextField(
              controller: athleteIdCtrl,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyLarge(),
              decoration: const InputDecoration(labelText: 'Athlete ID'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final id = int.tryParse(athleteIdCtrl.text);
                if (id == null) return;
                try {
                  await ref.read(attendanceRepositoryProvider).manualCheckIn(
                        athleteId: id,
                        trainingClassId: classId,
                      );
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppStrings.checkInSuccess)),
                    );
                    ref.invalidate(trainingClassDetailProvider(classId));
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Check In'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.titleSmall(color: color)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.6), size: 20),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/attendance.dart';
import '../../../../shared/widgets/app_shimmer.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../domain/attendance_provider.dart';

class DropInsScreen extends ConsumerWidget {
  const DropInsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final academyId = ref.watch(selectedAcademyIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.dropIns, style: AppTextStyles.titleLarge()),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
            onPressed: () => _showCreateDropIn(context, ref, academyId),
          ),
        ],
      ),
      body: academyId == null
          ? const EmptyView(icon: Icons.school_rounded, message: 'Select an academy')
          : _DropInsList(academyId: academyId),
    );
  }

  void _showCreateDropIn(BuildContext context, WidgetRef ref, int? academyId) {
    if (academyId == null) return;
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Register Drop-in', style: AppTextStyles.titleLarge()),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: firstNameCtrl,
                      decoration: const InputDecoration(labelText: 'First Name'),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: lastNameCtrl,
                      decoration: const InputDecoration(labelText: 'Last Name'),
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone (optional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  try {
                    await ref.read(attendanceRepositoryProvider).createDropIn(
                          academyId: academyId,
                          firstName: firstNameCtrl.text,
                          lastName: lastNameCtrl.text,
                          email: emailCtrl.text,
                          phone: phoneCtrl.text.isEmpty ? null : phoneCtrl.text,
                          expiresAt: DateTime.now().add(const Duration(hours: 24)),
                        );
                    ref.invalidate(dropInsProvider(academyId));
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropInsList extends ConsumerWidget {
  const _DropInsList({required this.academyId});

  final int academyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dropInsAsync = ref.watch(dropInsProvider(academyId));

    return dropInsAsync.when(
      loading: () => const ShimmerList(),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(dropInsProvider(academyId)),
      ),
      data: (page) {
        if (page.results.isEmpty) {
          return const EmptyView(
            icon: Icons.group_rounded,
            message: 'No drop-in visitors',
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async => ref.invalidate(dropInsProvider(academyId)),
          child: ListView.separated(
            padding: AppSpacing.screenPadding,
            itemCount: page.results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _DropInCard(visitor: page.results[i]),
          ),
        );
      },
    );
  }
}

class _DropInCard extends StatelessWidget {
  const _DropInCard({required this.visitor});

  final DropInVisitor visitor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surfaceVariant,
            child: Text(
              visitor.firstName.substring(0, 1).toUpperCase(),
              style: AppTextStyles.titleSmall(color: AppColors.muted),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visitor.fullName, style: AppTextStyles.titleSmall()),
                Text(visitor.email, style: AppTextStyles.bodySmall()),
                Text(
                  'Expires ${DateFormat('MMM d, h:mm a').format(visitor.expiresAt)}',
                  style: AppTextStyles.bodySmall(),
                ),
              ],
            ),
          ),
          StatusBadge.dropInStatus(visitor.status),
        ],
      ),
    );
  }
}

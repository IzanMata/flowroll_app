import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/athlete.dart';
import '../../../../shared/widgets/belt_badge.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/athletes_provider.dart';

class AthleteFormScreen extends ConsumerStatefulWidget {
  const AthleteFormScreen({super.key, this.athleteId});

  final int? athleteId;

  @override
  ConsumerState<AthleteFormScreen> createState() => _AthleteFormScreenState();
}

class _AthleteFormScreenState extends ConsumerState<AthleteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdCtrl = TextEditingController();
  BeltEnum? _belt;
  RoleEnum _role = RoleEnum.student;
  int _stripes = 0;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _userIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final academyId = ref.read(selectedAcademyIdProvider);
    if (academyId == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = ref.read(athletesRepositoryProvider);
      if (widget.athleteId != null) {
        await repo.updateAthlete(
          widget.athleteId!,
          belt: _belt,
          role: _role,
          stripes: _stripes,
        );
      } else {
        final userId = int.tryParse(_userIdCtrl.text);
        if (userId == null) {
          setState(() => _error = 'Invalid user ID');
          return;
        }
        await repo.createAthlete(
          userId: userId,
          academyId: academyId,
          belt: _belt,
          role: _role,
          stripes: _stripes,
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.athleteId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? AppStrings.editAthlete : AppStrings.addAthlete,
          style: AppTextStyles.titleLarge(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEditing) ...[
                TextFormField(
                  controller: _userIdCtrl,
                  keyboardType: TextInputType.number,
                  style: AppTextStyles.bodyLarge(),
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    prefixIcon: Icon(Icons.person_rounded),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),
              ],
              Text(AppStrings.belt, style: AppTextStyles.titleSmall()),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: BeltEnum.values.map((b) => BeltChip(
                      belt: b,
                      selected: _belt == b,
                      onTap: () => setState(() => _belt = b),
                    )).toList(),
              ),
              const SizedBox(height: 24),
              Text(AppStrings.role, style: AppTextStyles.titleSmall()),
              const SizedBox(height: 8),
              SegmentedButton<RoleEnum>(
                segments: const [
                  ButtonSegment(value: RoleEnum.student, label: Text('Student')),
                  ButtonSegment(value: RoleEnum.professor, label: Text('Professor')),
                ],
                selected: {_role},
                onSelectionChanged: (s) => setState(() => _role = s.first),
                style: SegmentedButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                  selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  selectedForegroundColor: AppColors.primary,
                  foregroundColor: AppColors.muted,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
              ),
              const SizedBox(height: 24),
              Text(AppStrings.stripes, style: AppTextStyles.titleSmall()),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (int i = 0; i <= 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _stripes = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _stripes == i
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _stripes == i ? AppColors.primary : AppColors.surfaceBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$i',
                              style: AppTextStyles.titleSmall(
                                color: _stripes == i ? AppColors.primary : AppColors.muted,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: AppTextStyles.bodySmall(color: AppColors.error)),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator(color: AppColors.onPrimary, strokeWidth: 2)
                    : Text(AppStrings.save, style: AppTextStyles.button()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

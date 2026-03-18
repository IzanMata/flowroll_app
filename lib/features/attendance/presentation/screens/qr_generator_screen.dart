import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/attendance_provider.dart';

class QrGeneratorScreen extends ConsumerStatefulWidget {
  const QrGeneratorScreen({super.key, required this.classId});

  final int classId;

  @override
  ConsumerState<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends ConsumerState<QrGeneratorScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Auto-refresh QR every 60s
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      ref.invalidate(qrCodeProvider(widget.classId));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qrAsync = ref.watch(qrCodeProvider(widget.classId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.generateQr, style: AppTextStyles.titleLarge()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () => ref.invalidate(qrCodeProvider(widget.classId)),
          ),
        ],
      ),
      body: qrAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(qrCodeProvider(widget.classId)),
        ),
        data: (qr) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // QR code
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: qr.token,
                          version: QrVersions.auto,
                          size: 260,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF0A0A0F),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF0A0A0F),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Scan to Check In',
                        style: AppTextStyles.titleMedium(color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Auto-refreshes every 60 seconds',
                        style: AppTextStyles.bodySmall(),
                      ),
                      const SizedBox(height: 16),
                      _ExpiryTimer(expiresAt: qr.expiresAt),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!qr.isValid)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'QR code expired — tap refresh',
                      style: AppTextStyles.bodySmall(color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpiryTimer extends StatefulWidget {
  const _ExpiryTimer({required this.expiresAt});

  final DateTime expiresAt;

  @override
  State<_ExpiryTimer> createState() => _ExpiryTimerState();
}

class _ExpiryTimerState extends State<_ExpiryTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    if (!mounted) return;
    setState(() {
      _remaining = widget.expiresAt.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seconds = _remaining.inSeconds;
    final color = seconds > 30
        ? AppColors.success
        : seconds > 10
            ? AppColors.warning
            : AppColors.error;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_rounded, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          'Expires in ${_remaining.inSeconds}s',
          style: AppTextStyles.labelMedium(color: color),
        ),
      ],
    );
  }
}

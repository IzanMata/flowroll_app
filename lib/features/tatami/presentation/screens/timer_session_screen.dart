import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../domain/tatami_provider.dart';

class TimerSessionScreen extends ConsumerStatefulWidget {
  const TimerSessionScreen({super.key, required this.presetId});

  final int presetId;

  @override
  ConsumerState<TimerSessionScreen> createState() => _TimerSessionScreenState();
}

class _TimerSessionScreenState extends ConsumerState<TimerSessionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timerSessionNotifierProvider.notifier).startSession(widget.presetId);
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timerSessionNotifierProvider);

    final elapsed = state.localElapsed;
    final total = state.totalSeconds;
    final remaining = (total - elapsed).clamp(0, total);
    final progress = total > 0 ? (1 - elapsed / total).clamp(0.0, 1.0) : 0.0;
    final timerColor = AppColors.timerColor(progress);

    final mm = (remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (remaining % 60).toString().padLeft(2, '0');

    final isRunning = state.isRunning;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              timerColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    if (state.session != null)
                      Text(state.session!.presetName, style: AppTextStyles.titleSmall()),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.timer_off_rounded, color: AppColors.error),
                      onPressed: () {
                        ref.read(timerSessionNotifierProvider.notifier).finish();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Round indicator
              if (state.session?.currentRound != null)
                Text(
                  'Round ${state.session!.currentRound}',
                  style: AppTextStyles.labelMedium(color: timerColor),
                ),
              const SizedBox(height: 20),
              // Main timer display with pulse animation
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Transform.scale(
                  scale: isRunning ? _pulse.value : 1.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress ring
                      SizedBox(
                        width: 280,
                        height: 280,
                        child: CustomPaint(
                          painter: _TimerRingPainter(
                            progress: progress,
                            color: timerColor,
                          ),
                        ),
                      ),
                      // Time text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$mm:$ss',
                            style: GoogleFonts.bebasNeue(
                              fontSize: 88,
                              color: timerColor,
                              letterSpacing: 4,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            isRunning
                                ? 'RUNNING'
                                : state.isPaused
                                    ? 'PAUSED'
                                    : state.isFinished
                                        ? 'FINISHED'
                                        : 'STARTING',
                            style: AppTextStyles.labelMedium(color: timerColor.withValues(alpha: 0.7)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Controls
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 48),
                child: state.isFinished
                    ? ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Done'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _ControlButton(
                              icon: isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              label: isRunning ? AppStrings.pauseTimer : AppStrings.resumeTimer,
                              color: timerColor,
                              onTap: () {
                                if (isRunning) {
                                  ref.read(timerSessionNotifierProvider.notifier).pause();
                                } else {
                                  ref.read(timerSessionNotifierProvider.notifier).resume();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ControlButton(
                              icon: Icons.stop_rounded,
                              label: AppStrings.finishTimer,
                              color: AppColors.error,
                              onTap: () {
                                ref.read(timerSessionNotifierProvider.notifier).finish();
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerRingPainter extends CustomPainter {
  _TimerRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = AppColors.surfaceVariant
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimerRingPainter old) =>
      old.progress != progress || old.color != color;
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
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
        height: 56,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.button(color: color)),
          ],
        ),
      ),
    );
  }
}

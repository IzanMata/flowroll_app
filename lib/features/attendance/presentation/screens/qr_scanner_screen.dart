import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../domain/attendance_provider.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _processing = false;
  bool _success = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    setState(() {
      _processing = true;
      _errorMessage = null;
    });

    try {
      await ref.read(attendanceRepositoryProvider).qrCheckIn(token: code);
      await HapticFeedback.heavyImpact();
      setState(() => _success = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.pop();
    } catch (e) {
      await HapticFeedback.vibrate();
      setState(() {
        _errorMessage = e.toString();
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Overlay
          _ScannerOverlay(success: _success),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: ValueListenableBuilder(
                      valueListenable: _controller.torchState,
                      builder: (_, state, __) => Icon(
                        state == TorchState.on
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _controller.toggleTorch,
                  ),
                ],
              ),
            ),
          ),
          // Bottom info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (_success) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(AppStrings.checkInSuccess,
                                style: AppTextStyles.titleSmall(color: Colors.white)),
                          ],
                        ),
                      ),
                    ] else if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(_errorMessage!,
                                style: AppTextStyles.bodySmall(color: Colors.white),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => setState(() {
                                _errorMessage = null;
                                _processing = false;
                              }),
                              child: Text(AppStrings.retry,
                                  style: AppTextStyles.button(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Point the camera at a QR code',
                        style: AppTextStyles.bodyMedium(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends StatefulWidget {
  const _ScannerOverlay({required this.success});

  final bool success;

  @override
  State<_ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<_ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const boxSize = 260.0;
    const cornerSize = 32.0;
    const cornerThickness = 4.0;

    final color = widget.success ? AppColors.success : AppColors.primary;

    return CustomPaint(
      size: screenSize,
      painter: _OverlayPainter(
        boxLeft: (screenSize.width - boxSize) / 2,
        boxTop: (screenSize.height - boxSize) / 2,
        boxSize: boxSize,
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Transform.scale(
            scale: _pulse.value,
            child: SizedBox(
              width: boxSize,
              height: boxSize,
              child: Stack(
                children: [
                  // Corners
                  for (final pos in _CornerPosition.values)
                    Positioned(
                      top: pos.top ? 0 : null,
                      bottom: pos.top ? null : 0,
                      left: pos.left ? 0 : null,
                      right: pos.left ? null : 0,
                      child: _Corner(
                        position: pos,
                        color: color,
                        size: cornerSize,
                        thickness: cornerThickness,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter({
    required this.boxLeft,
    required this.boxTop,
    required this.boxSize,
  });

  final double boxLeft;
  final double boxTop;
  final double boxSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final scanRect = Rect.fromLTWH(boxLeft, boxTop, boxSize, boxSize);
    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

enum _CornerPosition {
  topLeft(top: true, left: true),
  topRight(top: true, left: false),
  bottomLeft(top: false, left: true),
  bottomRight(top: false, left: false);

  const _CornerPosition({required this.top, required this.left});
  final bool top;
  final bool left;
}

class _Corner extends StatelessWidget {
  const _Corner({
    required this.position,
    required this.color,
    required this.size,
    required this.thickness,
  });

  final _CornerPosition position;
  final Color color;
  final double size;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          position: position,
          color: color,
          thickness: thickness,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({
    required this.position,
    required this.color,
    required this.thickness,
  });

  final _CornerPosition position;
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final h = size.height;
    final w = size.width;

    if (position.top && position.left) {
      canvas.drawLine(Offset(0, h), const Offset(0, 0), paint);
      canvas.drawLine(const Offset(0, 0), Offset(w, 0), paint);
    } else if (position.top && !position.left) {
      canvas.drawLine(Offset(0, 0), Offset(w, 0), paint);
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
    } else if (!position.top && position.left) {
      canvas.drawLine(const Offset(0, 0), Offset(0, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    } else {
      canvas.drawLine(Offset(w, 0), Offset(w, h), paint);
      canvas.drawLine(Offset(0, h), Offset(w, h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

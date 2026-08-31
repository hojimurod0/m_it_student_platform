import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';

/// Clean, transparent Gamification In-Progress Modal with Clash-of-Clans animated double hammers
class GamificationModal extends StatefulWidget {
  const GamificationModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      barrierDismissible: true,
      builder: (context) => const GamificationModal(),
    );
  }

  @override
  State<GamificationModal> createState() => _GamificationModalState();
}

class _GamificationModalState extends State<GamificationModal>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      behavior: HitTestBehavior.opaque,
      child: Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent tap through on the dialog box itself
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F1A2E).withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Animated Clash of Clans Double Hammers ──
                    SizedBox(
                      width: 140,
                      height: 120,
                      child: AnimatedBuilder(
                        animation: _controller!,
                        builder: (context, _) {
                          // Strike wave: smooth swing in and bounce back
                          final t = _controller?.value ?? 0.0;
                          // Sinusoidal bounce: swings from resting angle to strike angle
                          final strikeFactor = math.sin(t * math.pi * 2);

                          // Angle oscillation: -28deg to -8deg for left hammer
                          final leftAngle = -0.48 + (strikeFactor * 0.32);
                          // Angle oscillation: +28deg to +8deg for right hammer
                          final rightAngle = 0.48 - (strikeFactor * 0.32);

                          // Impact spark visibility at the peak of strike
                          final isStriking = (strikeFactor > 0.85);

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Impact Spark Glow
                              if (isStriking)
                                Positioned(
                                  top: 18,
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFFFFD700).withValues(alpha: 0.9),
                                          const Color(0xFFFFA500).withValues(alpha: 0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              // Left Hammer (Swinging from left)
                              Positioned(
                                left: 16,
                                bottom: 10,
                                child: Transform.rotate(
                                  angle: leftAngle,
                                  alignment: Alignment.bottomLeft,
                                  child: const _ClashHammer(isFacingRight: true),
                                ),
                              ),

                              // Right Hammer (Swinging from right)
                              Positioned(
                                right: 16,
                                bottom: 10,
                                child: Transform.rotate(
                                  angle: rightAngle,
                                  alignment: Alignment.bottomRight,
                                  child: const _ClashHammer(isFacingRight: false),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ── "Jarayonda" Text ──
                    Text(
                      context.tr('inProgressTitle'),
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white : const Color(0xFF00213D),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      context.tr('launchingSoon'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Single Clash-of-Clans style hammer with wood handle, metallic head and golden ring
class _ClashHammer extends StatelessWidget {
  const _ClashHammer({required this.isFacingRight});

  final bool isFacingRight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 72,
      child: CustomPaint(
        painter: _HammerPainter(isFacingRight: isFacingRight),
      ),
    );
  }
}

class _HammerPainter extends CustomPainter {
  const _HammerPainter({required this.isFacingRight});

  final bool isFacingRight;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Wooden Handle (Brown cylindrical stick)
    final handlePaint = Paint()
      ..color = const Color(0xFF8D5B28) // Rich Wood Brown
      ..style = PaintingStyle.fill;

    final handleHighlight = Paint()
      ..color = const Color(0xFFA76E36) // Light Wood Grain
      ..style = PaintingStyle.fill;

    final handlePath = Path();
    handlePath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.42, h * 0.22, w * 0.16, h * 0.72),
        const Radius.circular(4),
      ),
    );
    canvas.drawPath(handlePath, handlePaint);

    // Handle highlight line
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.25, w * 0.05, h * 0.65),
        const Radius.circular(2),
      ),
      handleHighlight,
    );

    // Handle grip tape wraps
    final gripPaint = Paint()
      ..color = const Color(0xFF5A3918)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(w * 0.42, h * 0.60), Offset(w * 0.58, h * 0.65), gripPaint);
    canvas.drawLine(Offset(w * 0.42, h * 0.72), Offset(w * 0.58, h * 0.77), gripPaint);

    // 2. Metallic Hammer Head (Steel Blue/Grey with Beveled Edges)
    final steelPaint = Paint()
      ..color = const Color(0xFF475569) // Dark Slate Steel
      ..style = PaintingStyle.fill;

    final steelLight = Paint()
      ..color = const Color(0xFF94A3B8) // Highlight Steel
      ..style = PaintingStyle.fill;

    final steelDark = Paint()
      ..color = const Color(0xFF1E293B) // Shadow Steel
      ..style = PaintingStyle.fill;

    // Base main block
    final headRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.18),
      width: w * 0.88,
      height: h * 0.28,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, const Radius.circular(5)),
      steelPaint,
    );

    // Top metal highlight
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.06, w * 0.80, h * 0.08),
        const Radius.circular(3),
      ),
      steelLight,
    );

    // Bottom metal shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.24, w * 0.80, h * 0.08),
        const Radius.circular(3),
      ),
      steelDark,
    );

    // Golden reinforcing band in the middle
    final goldPaint = Paint()
      ..color = const Color(0xFFF59E0B) // Gold
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.05, w * 0.24, h * 0.30),
        const Radius.circular(2),
      ),
      goldPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HammerPainter oldDelegate) => false;
}


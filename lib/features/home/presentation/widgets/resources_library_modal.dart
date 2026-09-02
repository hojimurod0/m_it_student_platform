import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';

/// Gamification-style Animated In-Progress Resources Modal
class ResourcesLibraryModal extends StatefulWidget {
  const ResourcesLibraryModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ResourcesLibraryModal(),
    );
  }

  @override
  State<ResourcesLibraryModal> createState() => _ResourcesLibraryModalState();
}

class _ResourcesLibraryModalState extends State<ResourcesLibraryModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: borderColor),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag Handle ──
          Center(
            child: Container(
              width: 42,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Animated Clash of Clans Double Hammers ──
          SizedBox(
            width: 140,
            height: 115,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, _) {
                final t = _animController.value;
                final strikeFactor = math.sin(t * math.pi * 2);

                final leftAngle = -0.48 + (strikeFactor * 0.32);
                final rightAngle = 0.48 - (strikeFactor * 0.32);
                final isStriking = (strikeFactor > 0.85);

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Impact Spark Glow
                    if (isStriking)
                      Positioned(
                        top: 16,
                        child: Container(
                          width: 34,
                          height: 34,
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

                    // Left Hammer
                    Positioned(
                      left: 16,
                      bottom: 10,
                      child: Transform.rotate(
                        angle: leftAngle,
                        alignment: Alignment.bottomLeft,
                        child: const _ClashHammer(isFacingRight: true),
                      ),
                    ),

                    // Right Hammer
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
          const SizedBox(height: 16),

          // ── In-Progress Title ──
          Text(
            context.tr('inProgressTitle'),
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'IT Kutubxona va Resurslar bo\'limi tez kunda ishga tushadi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 24),

          // ── Close Button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                AppHaptics.light();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.accentLime : AppColors.brandNavy,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                context.tr('close'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

    // 1. Wooden Handle
    final handlePaint = Paint()
      ..color = const Color(0xFF8D5B28)
      ..style = PaintingStyle.fill;

    final handleHighlight = Paint()
      ..color = const Color(0xFFA76E36)
      ..style = PaintingStyle.fill;

    final handlePath = Path();
    handlePath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.42, h * 0.22, w * 0.16, h * 0.72),
        const Radius.circular(4),
      ),
    );
    canvas.drawPath(handlePath, handlePaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.25, w * 0.05, h * 0.65),
        const Radius.circular(2),
      ),
      handleHighlight,
    );

    final gripPaint = Paint()
      ..color = const Color(0xFF5A3918)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(w * 0.42, h * 0.60), Offset(w * 0.58, h * 0.65), gripPaint);
    canvas.drawLine(Offset(w * 0.42, h * 0.72), Offset(w * 0.58, h * 0.77), gripPaint);

    // 2. Metallic Hammer Head
    final steelPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.fill;

    final steelLight = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.fill;

    final steelDark = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final headRect = Rect.fromCenter(
      center: Offset(w * 0.50, h * 0.18),
      width: w * 0.88,
      height: h * 0.28,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headRect, const Radius.circular(5)),
      steelPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.06, w * 0.80, h * 0.08),
        const Radius.circular(3),
      ),
      steelLight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.10, h * 0.24, w * 0.80, h * 0.08),
        const Radius.circular(3),
      ),
      steelDark,
    );

    final goldPaint = Paint()
      ..color = const Color(0xFFF59E0B)
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

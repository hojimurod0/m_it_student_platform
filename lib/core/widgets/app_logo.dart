import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 80,
    this.isLight = false,
    this.showBadge = true,
  });

  final double size;
  final bool isLight;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFD3FF32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD3FF32).withValues(alpha: 0.4),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
          BoxShadow(
            color: const Color(0xFF00213D).withValues(alpha: 0.12),
            blurRadius: size * 0.12,
            offset: Offset(0, size * 0.03),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.school_rounded,
                size: size * 0.5,
                color: const Color(0xFF00213D),
              ),
            );
          },
        ),
      ),
    );
  }
}

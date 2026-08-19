import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/constants/app_dimens.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';

enum MitToastType {
  info,
  success,
  warning,
  error,
}

class MitToast {
  MitToast._();

  static void show(
    BuildContext context, {
    required String message,
    MitToastType type = MitToastType.info,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final (Color bg, Color iconColor, IconData icon) = switch (type) {
      MitToastType.success => (
          const Color(0xFF064E3B),
          const Color(0xFF34D399),
          Icons.check_circle_rounded,
        ),
      MitToastType.warning => (
          const Color(0xFF78350F),
          const Color(0xFFFBBF24),
          Icons.warning_amber_rounded,
        ),
      MitToastType.error => (
          const Color(0xFF7F1D1D),
          const Color(0xFFF87171),
          Icons.error_outline_rounded,
        ),
      MitToastType.info => (
          const Color(0xFF0F172A),
          AppColors.primaryAccent,
          Icons.info_outline_rounded,
        ),
    };

    if (type == MitToastType.error) {
      AppHaptics.error();
    } else {
      AppHaptics.light();
    }

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: bg,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.r16,
          side: BorderSide(color: iconColor.withValues(alpha: 0.3)),
        ),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: action,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: MitToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: MitToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: MitToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: MitToastType.info);
  }
}

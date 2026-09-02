import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';

/// Centralized Feedback System for M-IT Student Platform.
/// Follows the strict rule: "One event = one primary feedback mechanism".
class AppFeedback {
  AppFeedback._();

  /// Shows standard top toast / notification
  static void showToast(
    BuildContext context, {
    required String message,
    String? title,
    MitToastType type = MitToastType.info,
  }) {
    MitToast.show(context, message: message, title: title, type: type);
  }

  /// Success toast
  static void success(BuildContext context, String message, {String? title}) {
    MitToast.success(context, message, title: title);
  }

  /// Error toast
  static void error(BuildContext context, String message, {String? title}) {
    MitToast.error(context, message, title: title);
  }

  /// Warning toast
  static void warning(BuildContext context, String message, {String? title}) {
    MitToast.warning(context, message, title: title);
  }

  /// Info toast
  static void info(BuildContext context, String message, {String? title}) {
    MitToast.info(context, message, title: title);
  }

  /// Shows standard SnackBar at bottom of screen
  static void showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isError) {
      AppHaptics.error();
    } else {
      AppHaptics.light();
    }

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError
            ? AppColors.danger
            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : const Color(0xFFCBD5E1),
          ),
        ),
        duration: duration,
        action: action,
      ),
    );
  }

  /// Shows standard destructive or confirmation modal dialog
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Ha, tasdiqlayman',
    String cancelText = 'Bekor qilish',
    bool isDestructive = false,
  }) {
    AppHaptics.warning();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDestructive ? AppColors.danger : theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.5,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () {
              AppHaptics.light();
              Navigator.pop(ctx, false);
            },
            child: Text(
              cancelText,
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (isDestructive) {
                AppHaptics.error();
              } else {
                AppHaptics.selection();
              }
              Navigator.pop(ctx, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.danger : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

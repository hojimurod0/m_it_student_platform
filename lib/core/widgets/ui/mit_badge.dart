import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/constants/app_dimens.dart';

enum MitBadgeVariant {
  primary,
  success,
  warning,
  danger,
  neutral,
}

class MitBadge extends StatelessWidget {
  const MitBadge({
    super.key,
    required this.label,
    this.variant = MitBadgeVariant.primary,
    this.icon,
    this.hasDot = false,
  });

  final String label;
  final MitBadgeVariant variant;
  final IconData? icon;
  final bool hasDot;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (Color bg, Color fg, Color border) = _getColors(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.rFull,
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fg,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ] else if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  (Color bg, Color fg, Color border) _getColors(bool isDark) {
    switch (variant) {
      case MitBadgeVariant.primary:
        return (
          isDark ? AppColors.primary.withValues(alpha: 0.18) : AppColors.primaryContainer,
          isDark ? AppColors.primaryAccent : AppColors.primaryDark,
          isDark ? AppColors.primaryAccent.withValues(alpha: 0.3) : AppColors.primaryDark.withValues(alpha: 0.25),
        );
      case MitBadgeVariant.success:
        return (
          isDark ? AppColors.success.withValues(alpha: 0.2) : const Color(0xFFDCFCE7),
          isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
          isDark ? AppColors.success.withValues(alpha: 0.3) : const Color(0xFF86EFAC),
        );
      case MitBadgeVariant.warning:
        return (
          isDark ? AppColors.warning.withValues(alpha: 0.2) : const Color(0xFFFEF3C7),
          isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
          isDark ? AppColors.warning.withValues(alpha: 0.3) : const Color(0xFFFDE68A),
        );
      case MitBadgeVariant.danger:
        return (
          isDark ? AppColors.danger.withValues(alpha: 0.2) : const Color(0xFFFEE2E2),
          isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
          isDark ? AppColors.danger.withValues(alpha: 0.3) : const Color(0xFFFCA5A5),
        );
      case MitBadgeVariant.neutral:
        return (
          isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
          isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        );
    }
  }
}

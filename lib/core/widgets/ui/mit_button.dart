import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/constants/app_dimens.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';

enum MitButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
}

class MitButton extends StatelessWidget {
  const MitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = MitButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final MitButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final childContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getForegroundColor(isDark),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: _getForegroundColor(isDark),
          ),
        ),
      ],
    );

    final buttonWidget = SizedBox(
      height: height,
      child: _buildBaseButton(context, isDark, childContent),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonWidget,
      );
    }
    return buttonWidget;
  }

  Color _getForegroundColor(bool isDark) {
    if (onPressed == null && !isLoading) {
      return isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    }
    switch (variant) {
      case MitButtonVariant.primary:
        return isDark ? const Color(0xFF00213D) : AppColors.textOnPrimary;
      case MitButtonVariant.secondary:
        return isDark ? AppColors.primaryAccent : AppColors.brandNavy;
      case MitButtonVariant.outline:
        return isDark ? AppColors.primaryAccent : AppColors.brandNavy;
      case MitButtonVariant.text:
        return isDark ? AppColors.primaryAccent : AppColors.brandNavy;
      case MitButtonVariant.danger:
        return Colors.white;
    }
  }

  Widget _buildBaseButton(BuildContext context, bool isDark, Widget child) {
    void handleTap() {
      if (isLoading || onPressed == null) return;
      AppHaptics.light();
      onPressed!();
    }

    switch (variant) {
      case MitButtonVariant.primary:
        return ElevatedButton(
          onPressed: (isLoading || onPressed == null) ? null : handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.primaryAccent : AppColors.primary,
            foregroundColor: isDark ? AppColors.brandNavy : Colors.white,
            disabledBackgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.r16),
            elevation: 0,
          ),
          child: child,
        );

      case MitButtonVariant.secondary:
        return FilledButton(
          onPressed: (isLoading || onPressed == null) ? null : handleTap,
          style: FilledButton.styleFrom(
            backgroundColor: isDark ? AppColors.primary.withValues(alpha: 0.18) : const Color(0xFFF1F5F9),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.r16),
            elevation: 0,
          ),
          child: child,
        );

      case MitButtonVariant.outline:
        return OutlinedButton(
          onPressed: (isLoading || onPressed == null) ? null : handleTap,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDark ? AppColors.primaryAccent : AppColors.brandNavy,
              width: 1.4,
            ),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.r16),
          ),
          child: child,
        );

      case MitButtonVariant.text:
        return TextButton(
          onPressed: (isLoading || onPressed == null) ? null : handleTap,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.r12),
          ),
          child: child,
        );

      case MitButtonVariant.danger:
        return ElevatedButton(
          onPressed: (isLoading || onPressed == null) ? null : handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.r16),
            elevation: 0,
          ),
          child: child,
        );
    }
  }
}

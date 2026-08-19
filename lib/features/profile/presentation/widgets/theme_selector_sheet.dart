import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';

class ThemeSelectorSheet extends StatelessWidget {
  const ThemeSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemeSelectorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentMode = context.settings.themeMode;

    final modes = [
      (ThemeMode.light, Icons.light_mode_rounded, context.tr('themeLight')),
      (ThemeMode.dark, Icons.dark_mode_rounded, context.tr('themeDark')),
      (ThemeMode.system, Icons.brightness_auto_rounded, context.tr('themeSystem')),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.tr('selectTheme'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          ...modes.map((item) {
            final isSelected = currentMode == item.$1;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.primary.withValues(alpha: 0.25) : AppColors.primarySurface)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                      : theme.colorScheme.outline,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: Icon(
                  item.$2,
                  color: isSelected
                      ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                      : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                ),
                title: Text(
                  item.$3,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? (isDark ? AppColors.primaryAccent : AppColors.primaryDark)
                        : theme.colorScheme.onSurface,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle_rounded, color: isDark ? AppColors.primaryAccent : AppColors.primary)
                    : null,
                onTap: () {
                  context.settings.setThemeMode(item.$1);
                  Navigator.pop(context);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

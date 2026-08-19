import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/constants/app_dimens.dart';
import 'package:m_it_student_platform/core/routes/app_routes.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_button.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sahifa topilmadi'),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.h24,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.explore_off_rounded,
                    size: 64,
                    color: isDark ? AppColors.primaryAccent : AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  '404',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Kechirasiz, siz qidirayotgan sahifa topilmadi yoki ko\'chirilgan bo\'lishi mumkin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                MitButton(
                  label: 'Bosh sahifaga qaytish',
                  icon: const Icon(Icons.arrow_back_rounded, size: 18, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.dashboard,
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/auth/domain/repositories/auth_repository.dart';

class ChangePasswordModal extends StatefulWidget {
  const ChangePasswordModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChangePasswordModal(),
    );
  }

  @override
  State<ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOld = false; // Start visible by default so user can clearly see/verify current password!
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    if (oldPass.isEmpty) {
      MitToast.warning(context, context.tr('oldPasswordRequired'));
      return;
    }
    if (newPass.isEmpty) {
      MitToast.warning(context, context.tr('newPasswordRequired'));
      return;
    }
    if (newPass.length < 4) {
      MitToast.warning(context, context.tr('passwordMinLength'));
      return;
    }
    if (newPass != confirmPass) {
      MitToast.warning(context, context.tr('passwordsDoNotMatch'));
      return;
    }

    setState(() => _isLoading = true);
    AppHaptics.medium();

    try {
      final authRepo = sl<AuthRepository>();
      await authRepo.changePassword(
        oldPassword: oldPass,
        newPassword: newPass,
      );

      if (!mounted) return;
      Navigator.pop(context);
      AppHaptics.medium();
      MitToast.success(context, context.tr('passwordUpdatedSuccess'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppHaptics.error();
      MitToast.error(
        context,
        e.toString().replaceAll('Exception:', '').replaceAll('AuthException:', '').trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF001E36) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? const Color(0xFF002F52) : const Color(0xFFE2E8F0),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.accentLime : AppColors.brandNavy).withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('changePasswordTitle'),
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF001E36),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Xavfsizlik uchun yangi parol o\'rnating',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 1. Old Password (with visible eye toggle)
            _buildPasswordField(
              label: context.tr('currentPasswordLabel'),
              controller: _oldPasswordController,
              isDark: isDark,
              obscureText: _obscureOld,
              onToggleVisibility: () => setState(() => _obscureOld = !_obscureOld),
            ),
            const SizedBox(height: 16),

            // 2. New Password
            _buildPasswordField(
              label: context.tr('newPasswordLabel'),
              controller: _newPasswordController,
              isDark: isDark,
              obscureText: _obscureNew,
              onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 16),

            // 3. Confirm New Password
            _buildPasswordField(
              label: context.tr('confirmPasswordLabel'),
              controller: _confirmPasswordController,
              isDark: isDark,
              obscureText: _obscureConfirm,
              onToggleVisibility: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 26),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.accentLime : AppColors.brandNavy,
                  foregroundColor: isDark ? const Color(0xFF001E36) : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? const Color(0xFF001E36) : Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        context.tr('updatePasswordButton'),
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFF001E36) : Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF001426) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF002F52) : const Color(0xFFCBD5E1),
              width: 1.1,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF001E36),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              hintText: '••••••••',
              hintStyle: TextStyle(
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 21,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

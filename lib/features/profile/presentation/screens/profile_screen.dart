import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/section_header.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';
import 'package:m_it_student_platform/features/profile/domain/repositories/profile_repository.dart';
import 'package:m_it_student_platform/features/profile/presentation/widgets/edit_profile_modal.dart';
import 'package:m_it_student_platform/features/profile/presentation/widgets/language_selector_sheet.dart';
import 'package:m_it_student_platform/features/profile/presentation/widgets/logout_dialog.dart';
import 'package:m_it_student_platform/features/profile/presentation/widgets/student_header_card.dart';
import 'package:m_it_student_platform/features/profile/presentation/widgets/theme_selector_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  late final ProfileRepository _profileRepo;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _profileRepo = sl.isRegistered<ProfileRepository>()
        ? sl<ProfileRepository>()
        : ProfileRepositoryImpl();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    try {
      await _profileRepo.getStudentProfile();
    } catch (_) {}
  }

  String _formatPhoneNumber(String phone) {
    final clean = phone.replaceAll(RegExp(r'\s+'), '');
    if (clean.isEmpty) return '';
    final digits = clean.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('998') && digits.length >= 12) {
      final code = digits.substring(3, 5);
      final p1 = digits.substring(5, 8);
      final p2 = digits.substring(8, 10);
      final p3 = digits.substring(10, 12);
      return '+998 $code $p1 $p2 $p3';
    } else if (digits.length == 9) {
      final code = digits.substring(0, 2);
      final p1 = digits.substring(2, 5);
      final p2 = digits.substring(5, 7);
      final p3 = digits.substring(7, 9);
      return '+998 $code $p1 $p2 $p3';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          color: const Color(0xFFD3FF32),
          child: ValueListenableBuilder<StudentProfile>(
            valueListenable: MockProfileRepository.studentNotifier,
            builder: (context, student, _) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                children: [
                  // ── 1. Student Profile Hero Card ──
                  StudentHeaderCard(
                    student: student,
                  ),
                  const SizedBox(height: 20),

                  // ── 2. Shaxsiy ma'lumotlar (Personal Information) ──
                  SectionHeader(
                    title: context.tr('personalInfo'),
                    fontSize: 13.5,
                  ),
                  const SizedBox(height: 8),
                  _GroupedSectionCard(
                    children: [
                      _PersonalInfoTile(
                      icon: Icons.phone_android_rounded,
                      iconColor: AppColors.secondary,
                      label: context.tr('phoneNumber'),
                      value: _formatPhoneNumber(student.phone),
                      onTap: () => EditProfileModal.show(context, student),
                    ),
                    _PersonalInfoTile(
                      icon: Icons.family_restroom_rounded,
                      iconColor: AppColors.accentPurple,
                      label: context.tr('parentPhone'),
                      value: student.parentPhone.isNotEmpty
                          ? _formatPhoneNumber(student.parentPhone)
                          : context.tr('notSpecified'),
                      onTap: () => EditProfileModal.show(context, student),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── 3. Sozlamalar (Preferences) ──
                SectionHeader(
                  title: context.tr('preferencesSettings'),
                  fontSize: 13.5,
                ),
                const SizedBox(height: 8),
                _GroupedSectionCard(
                  children: [
                    _ActionSettingTile(
                      icon: Icons.palette_outlined,
                      iconColor: AppColors.secondaryAccent,
                      title: context.tr('appearance'),
                      trailingWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(isDark ? '🌙' : '☀️',
                              style: const TextStyle(fontSize: 15)),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : AppColors.textMuted,
                          ),
                        ],
                      ),
                      onTap: () {
                        AppHaptics.selection();
                        ThemeSelectorSheet.show(context);
                      },
                    ),
                    _ActionSettingTile(
                      icon: Icons.translate_rounded,
                      iconColor: AppColors.info,
                      title: context.tr('appLanguage'),
                      trailingWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(context.language.flag,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 11,
                            color: isDark
                                ? const Color(0xFF64748B)
                                : AppColors.textMuted,
                          ),
                        ],
                      ),
                      onTap: () {
                        AppHaptics.selection();
                        LanguageSelectorSheet.show(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── 4. Ma'muriyat bilan bog'lanish va Chiqish (Without extra header) ──
                _GroupedSectionCard(
                  children: [
                    _ActionSettingTile(
                      icon: Icons.headset_mic_rounded,
                      iconColor: AppColors.secondary,
                      title: context.tr('helpSupport'),
                      onTap: () {
                        AppHaptics.selection();
                        _showSupportModal(context);
                      },
                    ),
                    _ActionSettingTile(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.danger,
                      title: context.tr('logout'),
                      titleColor: AppColors.danger,
                      trailingWidget: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.danger,
                      ),
                      onTap: () {
                        AppHaptics.error();
                        LogoutDialog.show(context);
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}

  void _showSupportModal(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.tr('supportModalTitle'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('supportModalDesc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _buildPhoneTile(
                ctx,
                title: context.tr('supportReception'),
                phone: '+998 71 200 00 00',
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(context.tr('close'), style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhoneTile(
    BuildContext context, {
    required String title,
    required String phone,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.phone_rounded, color: AppColors.success, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            tooltip: context.tr('copy'),
            onPressed: () {
              AppHaptics.selection();
              Clipboard.setData(ClipboardData(text: phone));
              MitToast.success(context, '$phone ${context.tr('copied')}');
            },
          ),
        ],
      ),
    );
  }
}

class _GroupedSectionCard extends StatelessWidget {
  const _GroupedSectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFF64748B).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 0.8,
                indent: 56,
                endIndent: 16,
                color: isDark
                    ? AppColors.darkDivider
                    : const Color(0xFFF1F5F9),
              ),
          ],
        ],
      ),
    );
  }
}

class _PersonalInfoTile extends StatelessWidget {
  const _PersonalInfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconColor = (isDark &&
            (iconColor == AppColors.primary ||
                iconColor == AppColors.brandNavy ||
                iconColor == const Color(0xFF00213D) ||
                iconColor == const Color(0xFF001426)))
        ? AppColors.accentLime
        : iconColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: isDark ? 0.22 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: effectiveIconColor.withValues(alpha: isDark ? 0.4 : 0.15),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Small label
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Large bold value
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionSettingTile extends StatelessWidget {
  const _ActionSettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.titleColor,
    this.trailingWidget,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Color? titleColor;
  final Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveIconColor = (isDark &&
            (iconColor == AppColors.primary ||
                iconColor == AppColors.brandNavy ||
                iconColor == const Color(0xFF00213D) ||
                iconColor == const Color(0xFF001426)))
        ? AppColors.accentLime
        : iconColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: isDark ? 0.22 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: effectiveIconColor.withValues(alpha: isDark ? 0.4 : 0.15),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: effectiveIconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: titleColor ?? theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (trailingWidget != null) ...[
                const SizedBox(width: 8),
                trailingWidget!,
              ] else ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

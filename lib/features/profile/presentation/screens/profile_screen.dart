import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/utils/phone_formatter.dart';
import 'package:m_it_student_platform/core/widgets/section_header.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';
import 'package:m_it_student_platform/features/profile/domain/repositories/profile_repository.dart';
import 'package:m_it_student_platform/features/profile/presentation/widgets/delete_account_modal.dart';
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

  Future<void> _openLegalUrl(String url) async {
    AppHaptics.selection();
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {
      try {
        final uri = Uri.parse(url);
        await launchUrl(uri);
      } catch (_) {}
    }
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

                  // ── 2. Shaxsiy ma'lumotlar (Personal Information - Read-Only) ──
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
                        value: student.phone.isNotEmpty
                            ? formatUzPhone(student.phone)
                            : context.tr('notSpecified'),
                        trailing: Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
                        ),
                        onTap: () {
                          if (student.phone.isNotEmpty) {
                            AppHaptics.selection();
                            Clipboard.setData(ClipboardData(text: formatUzPhone(student.phone)));
                            MitToast.info(context, '${formatUzPhone(student.phone)} ${context.tr('copied')}');
                          }
                        },
                      ),
                      _PersonalInfoTile(
                        icon: Icons.family_restroom_rounded,
                        iconColor: AppColors.accentPurple,
                        label: context.tr('parentPhone'),
                        value: student.parentPhone.isNotEmpty
                            ? formatUzPhone(student.parentPhone)
                            : context.tr('notSpecified'),
                        trailing: Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
                        ),
                        onTap: () {
                          if (student.parentPhone.isNotEmpty) {
                            AppHaptics.selection();
                            Clipboard.setData(ClipboardData(text: formatUzPhone(student.parentPhone)));
                            MitToast.info(context, '${formatUzPhone(student.parentPhone)} ${context.tr('copied')}');
                          } else {
                            MitToast.info(context, context.tr('parentInfoLocked'));
                          }
                        },
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
                const SizedBox(height: 18),

                // ── 4. Chiqish va Hisob amallari ──
                _GroupedSectionCard(
                  children: [
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
                        AppHaptics.medium();
                        LogoutDialog.show(context);
                      },
                    ),
                    _ActionSettingTile(
                      icon: Icons.person_remove_rounded,
                      iconColor: AppColors.danger,
                      title: context.tr('deleteAccount'),
                      subtitle: context.tr('deleteAccountSubtitle'),
                      titleColor: AppColors.danger,
                      trailingWidget: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.danger,
                      ),
                      onTap: () {
                        AppHaptics.warning();
                        DeleteAccountModal.show(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── 6. Maxfiylik va Shartlar (Login kabi pastki qismda) ──
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSecondary,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: context.tr('privacyPolicy'),
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _openLegalUrl(
                                  AppConfig.getPrivacyPolicyUrl(
                                      context.language.name),
                                ),
                        ),
                        const TextSpan(text: '   •   '),
                        TextSpan(
                          text: context.tr('termsOfService'),
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => _openLegalUrl(
                                  AppConfig.getTermsOfServiceUrl(
                                      context.language.name),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'M-IT Academy • v1.0.0 (Build 1)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
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
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

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
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Standard matching value size
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
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
    this.subtitle,
    this.titleColor,
    this.trailingWidget,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
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
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
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

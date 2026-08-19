import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/section_header.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';
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
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<StudentProfile>(
          valueListenable: MockProfileRepository.studentNotifier,
          builder: (context, student, _) {
            return ListView(
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
                    _SimpleProfileTile(
                      icon: Icons.person_rounded,
                      iconColor: isDark ? AppColors.accentLime : const Color(0xFF334155),
                      title: context.tr('fullName'),
                      subtitle: student.fullName,
                      showChevron: false,
                      onTap: () => EditProfileModal.show(context, student),
                    ),
                    _SimpleProfileTile(
                      icon: Icons.phone_android_rounded,
                      iconColor: AppColors.secondary,
                      title: context.tr('phoneNumber'),
                      subtitle: student.phone,
                      showChevron: false,
                      onTap: () => EditProfileModal.show(context, student),
                    ),
                    _SimpleProfileTile(
                      icon: Icons.family_restroom_rounded,
                      iconColor: AppColors.accentPurple,
                      title: context.tr('parentPhone'),
                      subtitle: student.parentPhone,
                      showChevron: false,
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
                    _SimpleProfileTile(
                      icon: Icons.palette_outlined,
                      iconColor: AppColors.secondaryAccent,
                      title: context.tr('appearance'),
                      subtitle: isDark
                          ? context.tr('themeDark')
                          : context.tr('themeLight'),
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
                    _SimpleProfileTile(
                      icon: Icons.translate_rounded,
                      iconColor: AppColors.info,
                      title: context.tr('appLanguage'),
                      subtitle: context.language.label,
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
                    _SimpleProfileTile(
                      icon: Icons.headset_mic_rounded,
                      iconColor: AppColors.secondary,
                      title: context.tr('helpSupport'),
                      subtitle: context.tr('supportPhone'),
                      onTap: () {
                        AppHaptics.light();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('supportPhoneSnack')),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    _SimpleProfileTile(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.danger,
                      title: context.tr('logout'),
                      subtitle: context.tr('logoutSub'),
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
    );
  }
}

class _GroupedSectionCard extends StatelessWidget {
  const _GroupedSectionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.75) // Sleek slate grey
        : Colors.white.withValues(alpha: 0.95);
    final borderColor = isDark
        ? const Color(0xFF334155).withValues(alpha: 0.8)
        : const Color(0xFFE2E8F0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0xFF64748B).withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
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
                        ? const Color(0xFF334155).withValues(alpha: 0.6)
                        : const Color(0xFFF1F5F9),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleProfileTile extends StatelessWidget {
  const _SimpleProfileTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
    this.trailingWidget,
    this.showChevron = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  final Widget? trailingWidget;
  final bool showChevron;

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
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: titleColor ?? theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingWidget != null) ...[
                const SizedBox(width: 8),
                trailingWidget!,
              ] else if (showChevron) ...[
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

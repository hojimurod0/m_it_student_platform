import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/student_avatar.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';
import 'package:m_it_student_platform/features/profile/presentation/widgets/edit_profile_modal.dart';

class StudentHeaderCard extends StatelessWidget {
  const StudentHeaderCard({super.key, required this.student});

  final StudentProfile student;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Neutral sleek grey / slate palette
    final cardGradient = isDark
        ? const LinearGradient(
            colors: [
              Color(0xFF263346), // Sleek Charcoal Slate
              Color(0xFF1E293B), // Medium Slate
              Color(0xFF141D2B), // Deep Slate Grey
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [
              Color(0xFFFFFFFF), // Pure Clean White
              Color(0xFFF8FAFC), // Slate-50
              Color(0xFFF1F5F9), // Slate-100 Soft Grey
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final borderColor = isDark
        ? const Color(0xFF475569).withValues(alpha: 0.6)
        : const Color(0xFFCBD5E1);

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : const Color(0xFF64748B).withValues(alpha: 0.1),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFF94A3B8).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: borderColor, width: 1.3),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── 1. Avatar on the Left (66px) ──
                GestureDetector(
                  onTap: () {
                    AppHaptics.selection();
                    EditProfileModal.show(context, student);
                  },
                  child: Tooltip(
                    message: context.tr('editProfile'),
                    child: StudentAvatar(
                      size: 66,
                      avatarEmoji: student.resolvedAvatarEmoji,
                      gender: student.gender,
                      initials: student.initials,
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                // ── 2. Info Column (Name + Pencil, Course, Group) ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Full Name + Inline Edit Pencil
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              student.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 19.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                                height: 1.15,
                                color: textColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Inline Edit Pencil Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                AppHaptics.selection();
                                EditProfileModal.show(context, student);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.accentLime.withValues(alpha: 0.15)
                                      : const Color(0xFF0F172A).withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.accentLime.withValues(alpha: 0.35)
                                        : const Color(0xFF0F172A).withValues(alpha: 0.12),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  size: 14,
                                  color: isDark
                                      ? AppColors.accentLime
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Course Name (Full width, clear readability)
                      Text(
                        student.courseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Dedicated Group Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.accentLime.withValues(alpha: 0.12)
                              : const Color(0xFF00213D).withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? AppColors.accentLime.withValues(alpha: 0.3)
                                : const Color(0xFF00213D).withValues(alpha: 0.12),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.groups_rounded,
                              size: 13,
                              color: isDark
                                  ? AppColors.accentLime
                                  : const Color(0xFF00213D),
                            ),
                            const SizedBox(width: 4.5),
                            Text(
                              student.group,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.accentLime
                                    : const Color(0xFF00213D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



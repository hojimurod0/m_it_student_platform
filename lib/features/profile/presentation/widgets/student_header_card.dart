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

    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 1. Avatar on the Left ──
          GestureDetector(
            onTap: () {
              AppHaptics.selection();
              EditProfileModal.show(context, student);
            },
            child: Tooltip(
              message: context.tr('editProfile'),
              child: StudentAvatar(
                size: 72,
                hasRing: false,
                avatarEmoji: student.resolvedAvatarEmoji,
                gender: student.gender,
                initials: student.initials,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // ── 2. Info Column (Name, Group) ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  student.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    height: 1.2,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.group.isNotEmpty ? student.group : student.courseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── 3. Edit Pencil Button ──
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                AppHaptics.selection();
                EditProfileModal.show(context, student);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.accentLime.withValues(alpha: 0.15)
                      : const Color(0xFF0F172A).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.accentLime.withValues(alpha: 0.35)
                        : const Color(0xFF0F172A).withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: isDark
                      ? AppColors.accentLime
                      : const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

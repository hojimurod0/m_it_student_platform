import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/widgets/student_avatar.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';

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
          // ── 1. Clean Avatar on the Left ──
          StudentAvatar(
            size: 72,
            hasRing: false,
            avatarEmoji: student.resolvedAvatarEmoji,
            gender: student.gender,
            initials: student.initials,
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
        ],
      ),
    );
  }
}

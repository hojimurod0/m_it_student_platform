import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    required this.onTap,
    this.showActions = true,
  });

  final Lesson lesson;
  final VoidCallback onTap;
  final bool showActions;

  Color _getStatusColor() {
    switch (lesson.status) {
      case LessonStatus.active:
        return AppColors.success;
      case LessonStatus.upcoming:
        return AppColors.primary;
      case LessonStatus.completed:
        return AppColors.textMuted;
      case LessonStatus.cancelled:
        return AppColors.danger;
    }
  }

  String _getStatusLabel(BuildContext context) {
    switch (lesson.status) {
      case LessonStatus.active:
        return context.tr('activeNow');
      case LessonStatus.upcoming:
        return context.tr('upcoming');
      case LessonStatus.completed:
        return context.tr('completed');
      case LessonStatus.cancelled:
        return context.tr('cancelled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor();

    final timeStr = lesson.startTime.isNotEmpty && lesson.endTime.isNotEmpty
        ? '${lesson.startTime} - ${lesson.endTime}'
        : (lesson.startTime.isNotEmpty ? lesson.startTime : '');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF001E36) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? (lesson.isActive ? const Color(0xFFD3FF32).withValues(alpha: 0.4) : const Color(0xFF002F52))
                  : (lesson.isActive ? const Color(0xFF769B00).withValues(alpha: 0.3) : const Color(0xFFE2E8F0)),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon container on the left
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFD3FF32).withValues(alpha: 0.15)
                      : const Color(0xFFD3FF32).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 22,
                    color: Color(0xFF769B00),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.subject.isNotEmpty
                                ? lesson.subject
                                : (lesson.syllabusTopic != null && lesson.syllabusTopic!.isNotEmpty
                                    ? lesson.syllabusTopic!
                                    : 'IT Darsi'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getStatusLabel(context),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (lesson.teacher.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_pin_rounded,
                            size: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lesson.teacher,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (timeStr.isNotEmpty || lesson.room.isNotEmpty || lesson.scheduleDays.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (timeStr.isNotEmpty) ...[
                            const Icon(
                              Icons.access_time_rounded,
                              size: 12.5,
                              color: Color(0xFF769B00),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF769B00),
                              ),
                            ),
                          ],
                          if (timeStr.isNotEmpty && lesson.room.isNotEmpty)
                            const SizedBox(width: 8),
                          if (lesson.room.isNotEmpty) ...[
                            Icon(
                              Icons.meeting_room_rounded,
                              size: 12.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                lesson.room,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                          if ((timeStr.isNotEmpty || lesson.room.isNotEmpty) && lesson.scheduleDays.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '•  ${context.formatScheduleDays(lesson.scheduleDays)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ] else if (lesson.scheduleDays.isNotEmpty)
                            Flexible(
                              child: Text(
                                context.formatScheduleDays(lesson.scheduleDays),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

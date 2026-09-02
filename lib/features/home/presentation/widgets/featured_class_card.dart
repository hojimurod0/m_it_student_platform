import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/services/reminder_service.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';

class FeaturedClassCard extends StatefulWidget {
  const FeaturedClassCard({
    super.key,
    required this.lesson,
    required this.onViewDetails,
  });

  final Lesson lesson;
  final VoidCallback onViewDetails;

  @override
  State<FeaturedClassCard> createState() => _FeaturedClassCardState();
}

class _FeaturedClassCardState extends State<FeaturedClassCard> {
  late bool _hasReminder;

  @override
  void initState() {
    super.initState();
    _hasReminder = ReminderService.isLessonReminderEnabled(widget.lesson.id);
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF00192E),
            Color(0xFF002747),
            Color(0xFF003866),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00192E).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle decorative element
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Branch/Track chip & Days badge & Reminder Bell
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.accentLime,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                (lesson.branchName != null && lesson.branchName!.isNotEmpty)
                                    ? lesson.branchName!
                                    : (lesson.courseCode.isNotEmpty ? lesson.courseCode : 'IT Guruhi'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (lesson.scheduleDays.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 11,
                                  color: AppColors.accentLime,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  context.formatScheduleDays(lesson.scheduleDays),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        // Reminder Bell Button
                        InkWell(
                          onTap: () async {
                            final newState = await ReminderService.toggleLessonReminder(context, lesson);
                            setState(() => _hasReminder = newState);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _hasReminder
                                  ? AppColors.accentLime.withValues(alpha: 0.25)
                                  : Colors.white.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _hasReminder ? AppColors.accentLime : Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              _hasReminder ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                              size: 15,
                              color: _hasReminder ? AppColors.accentLime : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Group Name / Subject (Main neon title)
                Text(
                  lesson.subject.isNotEmpty ? lesson.subject : 'IT Guruhi',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),

                if (lesson.syllabusTopic != null &&
                    lesson.syllabusTopic!.isNotEmpty &&
                    lesson.syllabusTopic != lesson.subject) ...[
                  const SizedBox(height: 4),
                  Text(
                    lesson.syllabusTopic!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                if (lesson.teacher.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.account_circle_rounded,
                        size: 17,
                        color: AppColors.accentLime,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "${context.tr('teacher')}: ${lesson.teacher}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Time & Room Row: Dars vaqti (chapda) va Dars xonasi (o'ngda)
                const SizedBox(height: 12),
                Row(
                  children: [
                    // 1. Dars soati (Time) — Left side
                    Expanded(
                      flex: 11,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_filled_rounded,
                              size: 14,
                              color: AppColors.accentLime,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                lesson.startTime.isNotEmpty
                                    ? (lesson.endTime.isNotEmpty
                                        ? '${lesson.startTime} – ${lesson.endTime}'
                                        : lesson.startTime)
                                    : '11:00 – 14:00',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 2. Dars xonasi (Room) — Right side
                    Expanded(
                      flex: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.meeting_room_rounded,
                              size: 14,
                              color: AppColors.accentLime,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                lesson.room.isNotEmpty
                                    ? lesson.room
                                    : (MockProfileRepository.currentStudent.room.isNotEmpty
                                        ? MockProfileRepository.currentStudent.room
                                        : '204-kompyuter xonasi'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Details Button in Neon Lime with Navy text
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onViewDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentLime,
                          foregroundColor: const Color(0xFF00213D),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.menu_book_rounded,
                          size: 17,
                          color: Color(0xFF00213D),
                        ),
                        label: Text(
                          context.tr('viewDetails'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF00213D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

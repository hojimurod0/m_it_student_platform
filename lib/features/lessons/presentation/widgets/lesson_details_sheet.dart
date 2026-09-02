import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/lessons/data/repositories/mock_lessons_repository.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';

class LessonDetailsSheet extends StatelessWidget {
  const LessonDetailsSheet({
    super.key,
    required this.lesson,
  });

  final Lesson lesson;

  static void show(BuildContext context, Lesson lesson) {
    AppHaptics.selection();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LessonDetailsSheet(lesson: lesson),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final student = MockProfileRepository.studentNotifier.value;

    // High-contrast Theme Colors
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    final sheetBg = isDark ? const Color(0xFF001426) : Colors.white;
    final cardBg = isDark ? const Color(0xFF001E36) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF002F52) : const Color(0xFFE2E8F0);

    // Fallbacks to guarantee 100% accurate data
    final effectiveSubject = lesson.subject.isNotEmpty ? lesson.subject : student.courseName;
    final effectiveTeacher = lesson.teacher.isNotEmpty ? lesson.teacher : student.mentorName;
    final effectiveTeacherRole = lesson.teacherRole.isNotEmpty ? lesson.teacherRole : 'Bosh mentor';
    final effectiveCourseCode = lesson.courseCode.isNotEmpty ? lesson.courseCode : student.group;
    final effectiveDays = lesson.scheduleDays.isNotEmpty ? lesson.scheduleDays : student.classDays;

    String effectiveTime = lesson.startTime;
    if (effectiveTime.isEmpty && student.classTime.isNotEmpty) {
      effectiveTime = student.classTime;
    } else if (lesson.endTime.isNotEmpty) {
      effectiveTime = '${lesson.startTime} – ${lesson.endTime}';
    }
    if (effectiveTime.isEmpty) effectiveTime = '11:00 – 14:00';

    final effectiveRoom = lesson.room.isNotEmpty && lesson.room != '3-xona'
        ? lesson.room
        : (student.room.isNotEmpty ? student.room : 'Google xonasi');
    final effectiveBranch = (lesson.branchName != null && lesson.branchName!.isNotEmpty)
        ? lesson.branchName!
        : 'M-IT Bosh filiali';

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag handle ──
            Center(
              child: Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Top Tags & Close Bar ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (effectiveCourseCode.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                          : const Color(0xFF00213D).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF38BDF8).withValues(alpha: 0.4)
                            : const Color(0xFF00213D).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      effectiveCourseCode,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF00213D),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                // Close button
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 22,
                    color: textPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  splashRadius: 18,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Main Subject Title ──
            Text(
              effectiveSubject,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: textPrimary,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),

            // ── Mentor Card ──
            if (effectiveTeacher.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFFD3FF32).withValues(alpha: 0.2)
                            : const Color(0xFF00213D).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 22,
                        color: isDark ? const Color(0xFFD3FF32) : const Color(0xFF00213D),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            effectiveTeacher,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            effectiveTeacherRole,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            // ── 2x2 Clean Detail Cards (Vaqt, Kun, Xona, Filial) ──
            Row(
              children: [
                Expanded(
                  child: _buildDetailBox(
                    icon: Icons.access_time_filled_rounded,
                    iconColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                    iconBg: isDark
                        ? const Color(0xFF38BDF8).withValues(alpha: 0.18)
                        : const Color(0xFF0284C7).withValues(alpha: 0.12),
                    label: 'Dars vaqti',
                    value: effectiveTime,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDetailBox(
                    icon: Icons.calendar_today_rounded,
                    iconColor: isDark ? const Color(0xFFD3FF32) : const Color(0xFF0D9488),
                    iconBg: isDark
                        ? const Color(0xFFD3FF32).withValues(alpha: 0.18)
                        : const Color(0xFF0D9488).withValues(alpha: 0.12),
                    label: context.tr('classDays'),
                    value: context.formatScheduleDays(effectiveDays, full: true),
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildDetailBox(
                    icon: Icons.meeting_room_rounded,
                    iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
                    iconBg: isDark
                        ? const Color(0xFFFBBF24).withValues(alpha: 0.18)
                        : const Color(0xFFD97706).withValues(alpha: 0.12),
                    label: 'Dars xonasi',
                    value: effectiveRoom,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDetailBox(
                    icon: Icons.location_on_rounded,
                    iconColor: isDark ? const Color(0xFF34D399) : const Color(0xFF7C3AED),
                    iconBg: isDark
                        ? const Color(0xFF34D399).withValues(alpha: 0.18)
                        : const Color(0xFF7C3AED).withValues(alpha: 0.12),
                    label: 'Filial',
                    value: effectiveBranch,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    cardBg: cardBg,
                    borderColor: borderColor,
                  ),
                ),
              ],
            ),

            // ── Dars Mavzusi / Syllabus Topic ──
            if (lesson.syllabusTopic != null && lesson.syllabusTopic!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 16,
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Dars mavzusi',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lesson.syllabusTopic!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            // ── Bottom Full-Width Action Button ──
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFFD3FF32) : const Color(0xFF00213D),
                  foregroundColor: isDark ? const Color(0xFF001426) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tushunarli',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBox({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required Color textPrimary,
    required Color textMuted,
    required Color cardBg,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class TopicDetailsSheet extends StatefulWidget {
  const TopicDetailsSheet({
    super.key,
    required this.topic,
    this.onSubmitted,
  });

  final TopicModel topic;
  final VoidCallback? onSubmitted;

  static void show(BuildContext context, TopicModel topic, {VoidCallback? onSubmitted}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TopicDetailsSheet(
        topic: topic,
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  State<TopicDetailsSheet> createState() => _TopicDetailsSheetState();
}

class _TopicDetailsSheetState extends State<TopicDetailsSheet> {
  final TextEditingController _urlController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.topic.submittedUrl != null) {
      _urlController.text = widget.topic.submittedUrl!;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _urlController.text.trim();
    if (text.isEmpty) {
      MitToast.warning(context, context.tr('homeworkRequiredError'));
      return;
    }

    setState(() => _isSubmitting = true);
    MockLessonsRepository.submitTopicHomework(widget.topic.id, text);

    MitToast.success(context, context.tr('homeworkSubmitted'));

    widget.onSubmitted?.call();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topic = widget.topic;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
              ),
              children: [
                // 1. Top IDE Code Snippet Header Banner (Screenshot 3 style)
                if (topic.codeSnippet != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                            const Spacer(),
                            const Text(
                              'main.cpp',
                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          topic.codeSnippet!,
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 11.5,
                            fontFamily: 'monospace',
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 2. Topic Title
                Text(
                  topic.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Attachments Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${context.tr('files')} (${topic.attachments.length})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (topic.remainingTime.isNotEmpty && topic.remainingTime != '-')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFEF4444)),
                            const SizedBox(width: 4),
                            Text(
                              '${topic.remainingTime} ${context.tr('remainingSuffix')}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // 4. Attachment Download Cards
                ...topic.attachments.map((file) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : theme.colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.accentLime.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.insert_drive_file_rounded,
                            size: 20,
                            color: isDark ? AppColors.accentLime : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                file.size,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.download_rounded),
                          color: isDark ? AppColors.accentLime : AppColors.primary,
                          onPressed: () {
                            MitToast.success(
                              context,
                              '${file.name} ${context.tr('materialDownloaded')}',
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),

                // 5. Rich Description Text
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : theme.colorScheme.outline,
                    ),
                  ),
                  child: Text(
                    topic.description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 6. Mening jo'natmalarim (My Submissions)
                Text(
                  context.tr('mySubmissions'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : theme.colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Folder Icon / Status
                      Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text('📁', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (topic.submittedUrl != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.success),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${context.tr('submittedPrefix')}: ${topic.submittedUrl}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          hintText: context.tr('githubSolutionHint'),
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF64748B) : AppColors.textMuted,
                          ),
                          prefixIcon: const Icon(Icons.link_rounded, size: 18),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.colorScheme.outline),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            topic.submittedUrl != null ? context.tr('resubmitHomework') : context.tr('submitHomework'),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
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
    );
  }
}

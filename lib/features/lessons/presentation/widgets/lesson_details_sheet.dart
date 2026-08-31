import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/services/reminder_service.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/lessons/data/repositories/mock_lessons_repository.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';

class LessonDetailsSheet extends StatelessWidget {
  const LessonDetailsSheet({
    super.key,
    required this.lesson,
  });

  final Lesson lesson;

  static void show(BuildContext context, Lesson lesson) {
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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const SizedBox(height: 18),
          Row(
            children: [
              if (lesson.courseCode.isNotEmpty) ...[
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primary.withValues(alpha: 0.25) : AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lesson.courseCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.primaryAccent : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  context.tr('inPersonClass'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  ReminderService.toggleLessonReminder(context, lesson);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accentLime.withValues(alpha: isDark ? 0.2 : 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.accentLime.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notifications_active_rounded, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('reminder'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.accentLime : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            lesson.subject,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (lesson.teacher.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              lesson.teacherRole.isNotEmpty
                  ? '${lesson.teacher} • ${lesson.teacherRole}'
                  : lesson.teacher,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Divider(color: theme.colorScheme.outline),
          const SizedBox(height: 14),

          // Schedule & Room Info Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                if (lesson.teacher.isNotEmpty)
                  _InfoRow(
                    icon: Icons.person_rounded,
                    label: context.tr('headMentor'),
                    value: '${lesson.teacher}${lesson.teacherRole.isNotEmpty ? ' (${lesson.teacherRole})' : ''}',
                  ),
                if (lesson.supportTeacher != null && lesson.supportTeacher!.isNotEmpty) ...[
                  if (lesson.teacher.isNotEmpty) const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.support_agent_rounded,
                    label: context.tr('assistantMentor'),
                    value: '${lesson.supportTeacher!}${lesson.supportTeacherRole != null && lesson.supportTeacherRole!.isNotEmpty ? ' (${lesson.supportTeacherRole})' : ''}',
                  ),
                ],
                if (lesson.startTime.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.access_time_filled_rounded,
                    label: context.tr('classSchedule'),
                    value: '${lesson.startTime} – ${lesson.endTime}${lesson.durationMinutes > 0 ? ' (${lesson.durationMinutes} min)' : ''}',
                  ),
                ],
                if (lesson.scheduleDays.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: context.tr('lessonDays'),
                    value: '${lesson.scheduleDays}${lesson.dayOfWeek.isNotEmpty && lesson.dayOfWeek != lesson.scheduleDays ? ' (${lesson.dayOfWeek})' : ''}',
                  ),
                ],
                if (lesson.room.isNotEmpty || (lesson.branchName != null && lesson.branchName!.isNotEmpty)) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.meeting_room_rounded,
                    label: context.tr('labRoom'),
                    value: '${lesson.room.isNotEmpty ? lesson.room : 'Asosiy xona'}${lesson.branchName != null && lesson.branchName!.isNotEmpty ? ', ${lesson.branchName}' : ''}',
                  ),
                ],
                if (lesson.monthlyFee != null && lesson.monthlyFee!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.payments_rounded,
                    label: context.tr('statMonthlyTuition'),
                    value: lesson.monthlyFee!,
                  ),
                ],
                if (lesson.studentCount != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.groups_rounded,
                    label: context.tr('groupStudentsCount'),
                    value: '${lesson.studentCount} ta talaba',
                  ),
                ],
              ],
            ),
          ),

          if (lesson.description != null && lesson.description!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              context.tr('aboutGroup'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lesson.description!,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary,
              ),
            ),
          ],

          if (lesson.syllabusTopic != null) ...[
            const SizedBox(height: 14),
            Text(
              context.tr('syllabusTopic'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lesson.syllabusTopic!,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary,
              ),
            ),
          ],

          if (lesson.notes != null) ...[
            const SizedBox(height: 12),
            Text(
              context.tr('studentNotes'),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lesson.notes!,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
              ),
            ),
          ],

          // Uy vazifasi bloki
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF001E36) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? const Color(0xFF002F52) : const Color(0xFFCBD5E1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.assignment_turned_in_rounded, size: 18, color: Color(0xFFD3FF32)),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('lessonTask'),
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF001E36),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3FF32).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.tr('submitAction'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF769B00),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  lesson.syllabusTopic != null && lesson.syllabusTopic!.isNotEmpty
                      ? '${lesson.syllabusTopic} • ${context.tr('doPracticalTasks')}'
                      : context.tr('doPracticalTasks'),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('close')),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            icon,
            size: 16,
            color: isDark ? AppColors.primaryAccent : AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ),
      ],
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

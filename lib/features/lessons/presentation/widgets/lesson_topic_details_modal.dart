import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/features/homework/presentation/widgets/submit_homework_modal.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Modal displaying detailed information for a single day's lesson and its homework
class LessonTopicDetailsModal extends StatelessWidget {
  const LessonTopicDetailsModal({
    super.key,
    required this.topic,
    required this.onSubmitted,
  });

  final TopicModel topic;
  final VoidCallback onSubmitted;

  static Future<void> show(
    BuildContext context, {
    required TopicModel topic,
    required VoidCallback onSubmitted,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LessonTopicDetailsModal(
        topic: topic,
        onSubmitted: onSubmitted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sheetBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final isGraded = topic.status == TopicStatus.done && topic.score != null;
    final isSubmitted = topic.status == TopicStatus.notSubmitted;
    final isDone = topic.status == TopicStatus.done;
    final isCompletedOrSubmitted = isDone || isSubmitted;
    final isPending = topic.status == TopicStatus.notDone && !isCompletedOrSubmitted;

    String statusLabelText;
    Color statusColor;

    if (isGraded) {
      statusLabelText = '${topic.score} ball (Baholandi)';
      statusColor = const Color(0xFF10B981);
    } else if (isCompletedOrSubmitted) {
      statusLabelText = 'Topshirilgan';
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusLabelText = 'Bajarilmagan';
      statusColor = const Color(0xFFEF4444);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag Handle ──
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Header Title & Close ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dars va Uyga vazifa',
                        style: TextStyle(
                          fontSize: 17.5,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        topic.givenDate.isNotEmpty ? topic.givenDate : '24-Avgust 2026',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.accentLime : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: subtitleColor, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),

          // ── Body Scrollable Content ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                // 1. Dars Mavzusi Card
                Container(
                  padding: const EdgeInsets.all(16),
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
                            size: 17,
                            color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'DARS MAVZUSI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        topic.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      if (topic.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          topic.description,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Dars Materiallari (agar bo'lsa)
                if (topic.attachments.isNotEmpty) ...[
                  Text(
                    'Dars Materiallari',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...topic.attachments.map((att) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file_rounded,
                            size: 20,
                            color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              att.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (att.downloadUrl.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.download_rounded, size: 20),
                              onPressed: () {
                                final uri = Uri.tryParse(att.downloadUrl);
                                if (uri != null) {
                                  launchUrl(uri, mode: LaunchMode.externalApplication);
                                }
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // 3. Ushbu Darsning Uyga Vazifasi Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.35),
                      width: 1.2,
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
                              Icon(
                                Icons.assignment_rounded,
                                size: 17,
                                color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'UYGA VAZIFA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor.withValues(alpha: 0.35)),
                            ),
                            child: Text(
                              statusLabelText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (topic.homeworkTitle != null && topic.homeworkTitle!.isNotEmpty) ...[
                        Text(
                          topic.homeworkTitle!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: topic.deadline.isNotEmpty
                                ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706))
                                : subtitleColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Muddat: ${topic.deadline.isNotEmpty ? topic.deadline : 'Muddatsiz'}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: topic.deadline.isNotEmpty
                                  ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706))
                                  : subtitleColor,
                            ),
                          ),
                        ],
                      ),
                      if (topic.homeworkDescription != null && topic.homeworkDescription!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            topic.homeworkDescription!,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Action Button: Topshirish or Status Info
                      if (isPending)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              AppHaptics.medium();
                              Navigator.of(context).pop();
                              await SubmitHomeworkModal.show(
                                context,
                                homeworkId: topic.homeworkId ?? topic.id,
                                homeworkTitle: topic.homeworkTitle ?? topic.title,
                              );
                              onSubmitted();
                            },
                            icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                            label: const Text(
                              'Vazifani topshirish',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppColors.accentLime : AppColors.brandNavy,
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        )
                      else if (isGraded)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star_rounded, size: 18, color: Color(0xFF10B981)),
                              const SizedBox(width: 6),
                              Text(
                                'Baholandi: ${topic.score} ball',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (isCompletedOrSubmitted)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hourglass_top_rounded, size: 16, color: Color(0xFFF59E0B)),
                              SizedBox(width: 6),
                              Text(
                                'Ustoz tekshiruvi kutilmoqda',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFF59E0B),
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
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/features/homework/data/repositories/homework_repository.dart';
import 'package:m_it_student_platform/features/homework/domain/models/homework_model.dart';

class HomeworkModal extends StatefulWidget {
  const HomeworkModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HomeworkModal(),
    );
  }

  @override
  State<HomeworkModal> createState() => _HomeworkModalState();
}

class _HomeworkModalState extends State<HomeworkModal> {
  final TextEditingController _githubController = TextEditingController();
  String? _selectedHomeworkId;

  @override
  void dispose() {
    _githubController.dispose();
    super.dispose();
  }

  void _submit(String hwId) {
    final text = _githubController.text.trim();
    if (text.isEmpty || !text.contains('github.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, to\'g\'ri GitHub repozitoriy havolasini kiriting! (masalan: https://github.com/...)'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HomeworkRepository.instance.submitHomework(hwId, text);
    setState(() {
      _selectedHomeworkId = null;
      _githubController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vazifa muvaffaqiyatli topshirildi! Mentor tez orada tekshiradi.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final list = HomeworkRepository.instance.homeworks;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.code_rounded, color: isDark ? AppColors.primaryAccent : AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uy Vazifalari & GitHub',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Amaliy kod topshirish va baholar',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Homework List
          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, i) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final hw = list[i];
                final isExpanded = _selectedHomeworkId == hw.id;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceSecondary : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Deadline Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(hw.status, isDark),
                          Text(
                            'Muddat: ${hw.deadline}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Title & Course
                      Text(
                        hw.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hw.course,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.primaryAccent : AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        hw.description,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        ),
                      ),

                      // Submitted Info / Feedback if available
                      if (hw.status == HomeworkStatus.submitted) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Baho: ${hw.score ?? 95}/100 ball',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              if (hw.mentorFeedback != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Mentor sharhi: ${hw.mentorFeedback}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      // Action Button or Input Field
                      if (hw.status == HomeworkStatus.pending) ...[
                        const SizedBox(height: 12),
                        if (!isExpanded)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => setState(() => _selectedHomeworkId = hw.id),
                              icon: const Icon(Icons.upload_file_rounded, size: 16),
                              label: const Text('GitHub linkini topshirish'),
                            ),
                          )
                        else ...[
                          TextField(
                            controller: _githubController,
                            decoration: InputDecoration(
                              hintText: 'https://github.com/username/repo',
                              labelText: 'GitHub Repository URL',
                              prefixIcon: const Icon(Icons.link_rounded),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => setState(() => _selectedHomeworkId = null),
                                  child: const Text('Bekor qilish'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _submit(hw.id),
                                  child: const Text('Topshirish'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(HomeworkStatus status, bool isDark) {
    return switch (status) {
      HomeworkStatus.pending => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.accentAmber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Kutilmoqda',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.accentAmber),
          ),
        ),
      HomeworkStatus.submitted => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Tekshirildi ✓',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.success),
          ),
        ),
      HomeworkStatus.reviewed => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Qayta ko\'rildi',
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.info),
          ),
        ),
    };
  }
}

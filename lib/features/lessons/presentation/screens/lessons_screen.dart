import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/features/lessons/data/repositories/mock_lessons_repository.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';
import 'package:m_it_student_platform/features/lessons/presentation/widgets/lesson_details_sheet.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedTab = 0; // 0 = Mavzular, 1 = Imtihon
  String _selectedCourse = MockLessonsRepository.availableCourses.first;

  @override
  bool get wantKeepAlive => true;

  void _showCourseSelector(BuildContext context) {
    AppHaptics.light();
    final theme = Theme.of(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'O\'quv guruhini tanlang',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...MockLessonsRepository.availableCourses.map((course) {
                final isSelected = course == _selectedCourse;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    course,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedCourse = course);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topics = MockLessonsRepository.topics;
    final newHomeworks = topics.where((t) => t.isNewHomework).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Header Title: Mavzular
            Container(
              color: theme.colorScheme.surface,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      context.tr('topicsTitle'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Course Dropdown Selector Button
                  GestureDetector(
                    onTap: () => _showCourseSelector(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedCourse,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 22,
                            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Tab Bar: Mavzular | Imtihon
                  Row(
                    children: [
                      _buildTabItem(0, context.tr('topicsTab'), isDark, theme),
                      _buildTabItem(1, context.tr('examsTab'), isDark, theme),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.colorScheme.outline),

            // Main Tab Content
            Expanded(
              child: _selectedTab == 0
                  ? _buildTopicsView(context, isDark, theme, topics, newHomeworks)
                  : _buildExamsView(context, isDark, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label, bool isDark, ThemeData theme) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_selectedTab != index) {
            AppHaptics.selection();
            setState(() => _selectedTab = index);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                    : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicsView(
    BuildContext context,
    bool isDark,
    ThemeData theme,
    List<TopicModel> topics,
    List<TopicModel> newHomeworks,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        AppHaptics.light();
        await Future<void>.delayed(const Duration(milliseconds: 350));
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
        // 1. 🔥 Yangi vazifalar (Screenshot 1)
        if (newHomeworks.isNotEmpty) ...[
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                context.tr('newHomework'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Emerald Banner Card
          _buildNewHomeworkBanner(newHomeworks.first, context, isDark),
          const SizedBox(height: 8),

          // Carousel Pagination Dots
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7D2FE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC7D2FE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 2. Vazifalar tarixi (Screenshot 1 Grid)
        Text(
          context.tr('homeworkHistory'),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            // Tekshirishni kutayotgan
            Expanded(
              child: _buildHistoryStatusCard(
                icon: Icons.access_time_filled_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFFEF3C7),
                title: context.tr('pendingReview'),
                count: MockLessonsRepository.pendingReviewCount,
                isDark: isDark,
                theme: theme,
              ),
            ),
            const SizedBox(width: 10),

            // Qaytarilgan vazifalar
            Expanded(
              child: _buildHistoryStatusCard(
                icon: Icons.assignment_return_rounded,
                iconColor: const Color(0xFFEF4444),
                iconBg: const Color(0xFFFEE2E2),
                title: context.tr('returnedHomework'),
                count: MockLessonsRepository.returnedCount,
                isDark: isDark,
                theme: theme,
              ),
            ),
            const SizedBox(width: 10),

            // Qabul qilingan vazifalar
            Expanded(
              child: _buildHistoryStatusCard(
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFD1FAE5),
                title: context.tr('acceptedHomework'),
                count: MockLessonsRepository.acceptedCount,
                isDark: isDark,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 3. Mavzular (Screenshot 1 & 2 Topic Cards)
        Text(
          context.tr('topicsTitle'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        ...topics.map((topic) => _buildTopicCard(topic, context, isDark, theme)),
        const SizedBox(height: 24),
      ],
    ));
  }

  Widget _buildNewHomeworkBanner(TopicModel topic, BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        TopicDetailsSheet.show(context, topic, onSubmitted: () => setState(() {}));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF059669),
              Color(0xFF10B981),
              Color(0xFF047857),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF059669).withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),

            if (topic.givenDate.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${context.tr('givenDateLabel')}: ${topic.givenDate}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],

            if (topic.deadline.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${context.tr('deadlineLabel')}: ${topic.deadline}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryStatusCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required int count,
    required bool isDark,
    required ThemeData theme,
  }) {
    return Container(
      height: 108,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFFCBD5E1) : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(
    TopicModel topic,
    BuildContext context,
    bool isDark,
    ThemeData theme,
  ) {
    Color badgeBg;
    Color badgeTextColor;
    String badgeText;

    switch (topic.status) {
      case TopicStatus.notDone:
        badgeBg = const Color(0xFFFEE2E2);
        badgeTextColor = const Color(0xFFDC2626);
        badgeText = context.tr('statusNotDone');
        break;
      case TopicStatus.done:
        badgeBg = const Color(0xFFD1FAE5);
        badgeTextColor = const Color(0xFF059669);
        badgeText = context.tr('statusDone');
        break;
      case TopicStatus.notSubmitted:
        badgeBg = const Color(0xFFEDE9FE);
        badgeTextColor = const Color(0xFF7C3AED);
        badgeText = context.tr('statusNotSubmitted');
        break;
      case TopicStatus.notGiven:
        badgeBg = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
        badgeTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
        badgeText = context.tr('statusNotGiven');
        break;
    }

    return GestureDetector(
      onTap: () {
        TopicDetailsSheet.show(context, topic, onSubmitted: () => setState(() {}));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    topic.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    topic.givenDate.isNotEmpty ? topic.givenDate : '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (topic.deadline.contains(':') || topic.deadline.contains('Noy')) ...[
                      const Icon(Icons.timer_outlined, size: 13, color: Color(0xFFEF4444)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      topic.deadline.isNotEmpty ? topic.deadline : '-',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: (topic.deadline.contains(':') || topic.deadline.contains('Noy'))
                            ? const Color(0xFFEF4444)
                            : (isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamsView(BuildContext context, bool isDark, ThemeData theme) {
    final exams = MockLessonsRepository.exams;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              'Imtihonlar va Baholar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...exams.map((exam) {
          final isPassed = exam.status == 'Topshirilgan';
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.colorScheme.outline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exam.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPassed
                            ? const Color(0xFFD1FAE5)
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFFEF3C7)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPassed ? 'Topshirilgan' : 'Kutilmoqda',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isPassed
                              ? const Color(0xFF059669)
                              : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  exam.description,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: isDark ? const Color(0xFFCBD5E1) : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(color: theme.colorScheme.outline),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          exam.date,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    if (exam.score != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Ball: ${exam.score}/100',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

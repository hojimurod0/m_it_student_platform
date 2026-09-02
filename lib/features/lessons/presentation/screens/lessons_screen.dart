import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/shimmer_loading.dart';
import 'package:m_it_student_platform/features/homework/data/repositories/homework_repository.dart';
import 'package:m_it_student_platform/features/lessons/data/repositories/lessons_repository_impl.dart';
import 'package:m_it_student_platform/features/lessons/data/repositories/mock_lessons_repository.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';
import 'package:m_it_student_platform/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:m_it_student_platform/features/lessons/presentation/widgets/lesson_topic_details_modal.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen>
    with AutomaticKeepAliveClientMixin {
  late final LessonsRepository _lessonsRepo;

  String _selectedFilter = 'all'; // 'all', 'done', 'pending'
  List<TopicModel> _topics = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _lessonsRepo = sl.isRegistered<LessonsRepository>()
        ? sl<LessonsRepository>()
        : LessonsRepositoryImpl();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadLessonsData();
      }
    });
  }

  Future<void> _loadLessonsData() async {
    if (!mounted) return;
    if (_topics.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final results = await Future.wait([
        _lessonsRepo.getLessonTopics().catchError((_) => <TopicModel>[]),
        HomeworkRepository.instance.getHomeworks(forceRefresh: true).catchError((_) => <HomeworkItem>[]),
      ]);

      if (!mounted) return;

      final rawTopics = results[0] as List<TopicModel>;
      final homeworks = results[1] as List<HomeworkItem>;

      final topicsList = rawTopics.isNotEmpty
          ? rawTopics
          : (AppConfig.useMockData && homeworks.isEmpty ? MockLessonsRepository.topics : <TopicModel>[]);

      setState(() {
        _topics = _mergeTopicsWithHomeworks(topicsList, homeworks);
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          if (_topics.isEmpty && AppConfig.useMockData) {
            _topics = MockLessonsRepository.topics;
          }
          _isLoading = false;
        });
      }
    }
  }

  List<TopicModel> _mergeTopicsWithHomeworks(List<TopicModel> topics, List<HomeworkItem> homeworks) {
    final List<TopicModel> merged = [];
    final Set<String> matchedHwIds = {};

    // 1. Process all lessons from lessons API as the primary lesson list
    for (final t in topics) {
      final matchIndex = homeworks.indexWhere((hw) {
        if (hw.lessonId != null && hw.lessonId!.isNotEmpty && hw.lessonId == t.id) {
          return true;
        }
        if (hw.lessonTitle != null && hw.lessonTitle!.trim().isNotEmpty &&
            hw.lessonTitle!.trim().toLowerCase() == t.title.trim().toLowerCase()) {
          return true;
        }
        if (hw.title.trim().toLowerCase() == t.title.trim().toLowerCase()) {
          return true;
        }
        return false;
      });

      final HomeworkItem? match = matchIndex != -1 ? homeworks[matchIndex] : null;
      if (match != null) {
        matchedHwIds.add(match.id);
      }

      final isLocallySubmitted = HomeworkRepository.instance.isHomeworkSubmitted(t.id, title: t.title) ||
          (match != null && HomeworkRepository.instance.isHomeworkSubmitted(match.id, title: match.title));

      final score = match?.score ?? t.score;
      final status = (score != null)
          ? TopicStatus.done
          : (isLocallySubmitted || (match != null && (match.status == HomeworkStatus.submitted || match.status == HomeworkStatus.reviewed))
              ? TopicStatus.notSubmitted
              : (match != null ? TopicStatus.notDone : t.status));

      final attachments = <TopicAttachment>[...t.attachments];
      if (match?.attachmentUrl != null && match!.attachmentUrl!.isNotEmpty) {
        final attUrl = match.attachmentUrl!;
        if (!attachments.any((a) => a.downloadUrl == attUrl)) {
          attachments.add(
            TopicAttachment(
              name: attUrl.split('/').last,
              size: 'PDF',
              downloadUrl: attUrl,
            ),
          );
        }
      }

      final normalized = t.copyWith(
        id: t.id,
        title: t.title, // Mavzu nomi doimo darsning asl nomi bo'ladi
        status: status,
        givenDate: t.givenDate.isNotEmpty ? t.givenDate : (match?.deadline ?? '1-Sentabr 2026'),
        deadline: (match != null && match.deadline.isNotEmpty) ? match.deadline : t.deadline,
        score: score,
        homeworkId: match?.id,
        homeworkTitle: match?.title, // Masalan: "Vazifa API yozish"
        homeworkDescription: match?.description,
        attachments: attachments,
      );

      merged.add(normalized);
    }

    // 2. Add any unmatched orphan homeworks that didn't have a matching lesson in topics
    for (final hw in homeworks) {
      if (!matchedHwIds.contains(hw.id)) {
        final lessonTitle = (hw.lessonTitle != null && hw.lessonTitle!.trim().isNotEmpty)
            ? hw.lessonTitle!.trim()
            : hw.title.trim();
        final homeworkTitle = (hw.lessonTitle != null &&
                hw.lessonTitle!.trim().isNotEmpty &&
                hw.lessonTitle!.trim() != hw.title.trim())
            ? hw.title.trim()
            : null;

        final isLocallySubmitted = HomeworkRepository.instance.isHomeworkSubmitted(hw.id, title: hw.title);
        final score = hw.score;
        final status = (score != null)
            ? TopicStatus.done
            : (isLocallySubmitted || hw.status == HomeworkStatus.submitted || hw.status == HomeworkStatus.reviewed
                ? TopicStatus.notSubmitted
                : TopicStatus.notDone);

        final attachments = (hw.attachmentUrl != null && hw.attachmentUrl!.isNotEmpty)
            ? [
                TopicAttachment(
                  name: hw.attachmentUrl!.split('/').last,
                  size: 'PDF',
                  downloadUrl: hw.attachmentUrl!,
                ),
              ]
            : <TopicAttachment>[];

        merged.add(
          TopicModel(
            id: hw.lessonId ?? hw.id,
            courseId: hw.course,
            title: lessonTitle,
            status: status,
            givenDate: hw.deadline.isNotEmpty ? hw.deadline : '1-Sentabr 2026',
            deadline: hw.deadline,
            description: (hw.description.isNotEmpty)
                ? hw.description
                : 'Ushbu dars bo\'yicha amaliy mashg\'ulotlar va nazariy bilimlar beriladi.',
            score: score,
            homeworkId: hw.id,
            homeworkTitle: homeworkTitle ?? hw.title,
            homeworkDescription: hw.description,
            attachments: attachments,
            order: _extractNum(hw.lessonId ?? hw.id, lessonTitle),
          ),
        );
        matchedHwIds.add(hw.id);
      }
    }

    // 3. Fallback to mock topics only if completely empty
    if (merged.isEmpty) {
      merged.addAll(MockLessonsRepository.topics);
    }

    // 4. Sort newest / latest added lessons on top (descending)
    merged.sort((a, b) {
      if (a.createdAt != null && b.createdAt != null && a.createdAt!.isNotEmpty && b.createdAt!.isNotEmpty) {
        try {
          final dtA = DateTime.parse(a.createdAt!);
          final dtB = DateTime.parse(b.createdAt!);
          final cmp = dtB.compareTo(dtA);
          if (cmp != 0) return cmp;
        } catch (_) {}
      }

      if (a.order != 0 || b.order != 0) {
        final cmp = b.order.compareTo(a.order);
        if (cmp != 0) return cmp;
      }

      final aNum = _extractNum(a.id, a.title);
      final bNum = _extractNum(b.id, b.title);
      if (aNum != 0 || bNum != 0) {
        final cmp = bNum.compareTo(aNum);
        if (cmp != 0) return cmp;
      }

      return 0;
    });

    return merged;
  }

  int _extractNum(String id, String title) {
    final titleMatch = RegExp(r'(\d+)').firstMatch(title);
    if (titleMatch != null) {
      final parsed = int.tryParse(titleMatch.group(1)!);
      if (parsed != null && parsed > 0) return parsed;
    }
    final idDigits = id.replaceAll(RegExp(r'[^\d]'), '');
    if (idDigits.isNotEmpty) {
      final parsed = int.tryParse(idDigits);
      if (parsed != null && parsed > 0) return parsed;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF8FAFC);
    final allTopics = _topics;

    final filteredTopics = switch (_selectedFilter) {
      'done' => allTopics.where((t) => t.status == TopicStatus.done).toList(),
      'pending' => allTopics.where((t) => t.status == TopicStatus.notDone || t.status == TopicStatus.notSubmitted || t.status == TopicStatus.notGiven).toList(),
      _ => allTopics,
    };

    final doneCount = allTopics.where((t) => t.status == TopicStatus.done).length;
    final pendingCount = allTopics.where((t) => t.status == TopicStatus.notDone || t.status == TopicStatus.notSubmitted || t.status == TopicStatus.notGiven).length;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Clean Top Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                context.tr('navLessons'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.brandNavy,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            // ── 2. Simple Filter Chips ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Barchasi (${allTopics.length})',
                      isSelected: _selectedFilter == 'all',
                      isDark: isDark,
                      onTap: () => setState(() => _selectedFilter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Bajarilgan ($doneCount)',
                      isSelected: _selectedFilter == 'done',
                      isDark: isDark,
                      activeColor: const Color(0xFF10B981),
                      onTap: () => setState(() => _selectedFilter = 'done'),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Bajarilmagan ($pendingCount)',
                      isSelected: _selectedFilter == 'pending',
                      isDark: isDark,
                      activeColor: const Color(0xFFEF4444),
                      onTap: () => setState(() => _selectedFilter = 'pending'),
                    ),
                  ],
                ),
              ),
            ),

            // ── 3. Lessons Cards List (Tapping opens full lesson & homework details) ──
            Expanded(
              child: _isLoading
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      children: const [
                        ShimmerCardSkeleton(height: 150),
                        SizedBox(height: 12),
                        ShimmerCardSkeleton(height: 150),
                        SizedBox(height: 12),
                        ShimmerCardSkeleton(height: 150),
                      ],
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLessonsData,
                      color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                      child: filteredTopics.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.task_alt_rounded,
                                    size: 48,
                                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Darslar topilmadi',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              itemCount: filteredTopics.length,
                              itemBuilder: (context, index) {
                                return _buildLessonItemCard(
                                  filteredTopics[index],
                                  isDark,
                                  theme,
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final effectiveColor = activeColor ?? (isDark ? AppColors.accentLime : AppColors.brandNavy);

    return InkWell(
      onTap: () {
        AppHaptics.selection();
        onTap();
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? (isDark && activeColor == null ? Colors.black : Colors.white)
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  // ── Reference Structured Card (Clean, Single Status Badge, Tap to view Lesson details) ──
  Widget _buildLessonItemCard(TopicModel topic, bool isDark, ThemeData theme) {
    final cardBg = isDark ? const Color(0xFF111927) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E2D42) : const Color(0xFFE2E8F0);
    final headerBg = isDark ? const Color(0xFF162235) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    // Status logic (Single source of truth)
    final isGraded = topic.status == TopicStatus.done && topic.score != null;
    final isSubmitted = topic.status == TopicStatus.notSubmitted;
    final isDone = topic.status == TopicStatus.done;
    final isCompletedOrSubmitted = isDone || isSubmitted;

    String statusLabelText;
    Color statusBadgeColor;
    IconData statusIcon;

    if (isGraded) {
      statusLabelText = '${topic.score} ball (Baholandi)';
      statusBadgeColor = const Color(0xFF10B981);
      statusIcon = Icons.star_rounded;
    } else if (isCompletedOrSubmitted) {
      statusLabelText = 'Topshirilgan';
      statusBadgeColor = const Color(0xFFF59E0B);
      statusIcon = Icons.hourglass_top_rounded;
    } else {
      statusLabelText = 'Bajarilmagan';
      statusBadgeColor = const Color(0xFFEF4444);
      statusIcon = Icons.error_outline_rounded;
    }

    return InkWell(
      onTap: () {
        AppHaptics.light();
        LessonTopicDetailsModal.show(
          context,
          topic: topic,
          onSubmitted: _loadLessonsData,
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF1E2D42) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Mavzular Highlighted Header Row
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                color: headerBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.accentLime : AppColors.brandNavy).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MAVZU',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isDark ? AppColors.accentLime : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          topic.title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                            color: textColor,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: subtitleColor,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),

            // 2. Uyga vazifa Holati Row (Single clear status badge)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Uyga vazifa',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: subtitleColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBadgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: statusBadgeColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusBadgeColor),
                            const SizedBox(width: 4),
                            Text(
                              statusLabelText,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: statusBadgeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),

            // 3. Uyga vazifa tugash vaqti Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      'Tugash vaqti',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: subtitleColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      topic.deadline.isNotEmpty ? topic.deadline : 'Muddatsiz',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: topic.deadline.isNotEmpty
                            ? (isDark ? const Color(0xFFFDE68A) : const Color(0xFFD97706))
                            : subtitleColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),

            // 4. Dars sanasi & Batafsil CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dars sanasi
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dars sanasi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        topic.givenDate.isNotEmpty ? topic.givenDate : '24-Avgust 2026',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),

                  // Batafsil CTA
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Batafsil',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: isDark ? AppColors.accentLime : AppColors.brandNavy,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

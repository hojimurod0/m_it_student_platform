import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/storage/app_cache_service.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/shimmer_loading.dart';
import 'package:m_it_student_platform/features/home/domain/repositories/home_repository.dart';
import 'package:m_it_student_platform/features/lessons/data/repositories/lessons_repository_impl.dart';
import 'package:m_it_student_platform/features/lessons/data/repositories/mock_lessons_repository.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';
import 'package:m_it_student_platform/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:m_it_student_platform/features/lessons/presentation/widgets/lesson_details_sheet.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen>
    with AutomaticKeepAliveClientMixin {
  late final LessonsRepository _lessonsRepo;

  TopicStatus? _activeStatusFilter;
  Lesson? _activeLesson;
  List<TopicModel> _topics = [];
  bool _isLessonsLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _lessonsRepo = sl.isRegistered<LessonsRepository>()
        ? sl<LessonsRepository>()
        : LessonsRepositoryImpl();

    // Instant offline-cache hydration
    final cachedFeatured = AppCacheService.getCache(AppCacheService.keyFeaturedClass);
    if (cachedFeatured is Map<String, dynamic>) {
      _activeLesson = Lesson.fromJson(cachedFeatured);
      _isLessonsLoading = false;
    }
    final cachedLessons = AppCacheService.getCache(AppCacheService.keyLessons);
    if (cachedLessons is List && _activeLesson == null) {
      final list = cachedLessons.whereType<Map<String, dynamic>>().map(Lesson.fromJson).toList();
      if (list.isNotEmpty) {
        _activeLesson = list.first;
        _isLessonsLoading = false;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadLessonsData();
      }
    });
  }

  Future<void> _loadLessonsData() async {
    if (!mounted) return;
    if (_activeLesson == null && _topics.isEmpty) {
      setState(() => _isLessonsLoading = true);
    }

    try {
      final results = await Future.wait([
        _lessonsRepo.getTodayLessons().catchError((_) => <Lesson>[]),
        _lessonsRepo.getLessonTopics().catchError((_) => <TopicModel>[]),
        sl<HomeRepository>().getFeaturedClass().catchError((_) => MockLessonsRepository.todayLessons.first),
      ]);

      if (!mounted) return;

      final todayLessons = results[0] as List<Lesson>;
      final topics = results[1] as List<TopicModel>;
      final featured = results[2] as Lesson;

      setState(() {
        if (todayLessons.isNotEmpty) {
          _activeLesson = todayLessons.first;
        } else {
          _activeLesson ??= featured;
        }
        if (topics.isNotEmpty) {
          _topics = topics;
        } else if (_topics.isEmpty) {
          _topics = MockLessonsRepository.topics;
        }
        _isLessonsLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          if (_topics.isEmpty) _topics = MockLessonsRepository.topics;
          _activeLesson ??= MockLessonsRepository.todayLessons.first;
          _isLessonsLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allTopics = _topics;
    final filteredTopics = _activeStatusFilter == null
        ? allTopics
        : allTopics.where((t) => t.status == _activeStatusFilter).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Header (Har doim ochiq, Shimmersiz)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('navLessons'),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3FF32).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD3FF32).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_rounded, size: 14, color: Color(0xFF769B00)),
                        const SizedBox(width: 5),
                        Text(
                          '${allTopics.length} ${context.tr('lessonsCount')}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF769B00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Body: Darslar va Mavzular (Sarlavhalar statik, kartalarga esa o'lchami bir xil shimmer berilgan)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadLessonsData,
                color: const Color(0xFFD3FF32),
                backgroundColor: isDark ? const Color(0xFF001E36) : Colors.white,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
                  children: [
                    // 1. Active Lesson Card (Yuklanayotganda o'z o'lchamida shimmer)
                    if (_isLessonsLoading)
                      const ShimmerCardSkeleton(height: 165)
                    else if (_activeLesson != null)
                      _buildActiveLessonCard(_activeLesson!, isDark, theme),
                    const SizedBox(height: 20),

                    // 2. Topics Header with Filter (Har doim ochiq, Shimmersiz)
                    _buildTopicsHeader(context, isDark, theme, allTopics),
                    const SizedBox(height: 12),

                    // 3. Topics & Homework List (Yuklanayotganda o'z o'lchamida card shimmer)
                    if (_isLessonsLoading)
                      const ShimmerTopicListSkeleton(itemCount: 4)
                    else if (filteredTopics.isEmpty)
                      _buildEmptyTopics(isDark)
                    else
                      ...filteredTopics.map(
                        (topic) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildTopicTile(topic, isDark, theme),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveLessonCard(Lesson lesson, bool isDark, ThemeData theme) {
    final lessonTimeString = lesson.startTime.isNotEmpty && lesson.endTime.isNotEmpty
        ? '${lesson.startTime} - ${lesson.endTime}'
        : (lesson.startTime.isNotEmpty ? lesson.startTime : '');

    final activeTopic = _topics.isNotEmpty ? _topics.first : null;
    final topicTitle = (activeTopic != null && activeTopic.title.isNotEmpty)
        ? activeTopic.title
        : (lesson.syllabusTopic != null && lesson.syllabusTopic!.isNotEmpty ? lesson.syllabusTopic! : '');
    final hasDistinctTopic = topicTitle.isNotEmpty && topicTitle != lesson.subject;
    final mainTitle = hasDistinctTopic ? topicTitle : (lesson.subject.isNotEmpty ? lesson.subject : 'Bugungi dars');
    final subtitleText = hasDistinctTopic && lesson.subject.isNotEmpty ? '${context.tr('groupPrefix')}: ${lesson.subject}' : null;

    return GestureDetector(
      onTap: () {
        AppHaptics.light();
        LessonDetailsSheet.show(context, lesson);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF001F3D), const Color(0xFF00305C)]
                : [const Color(0xFF00274D), const Color(0xFF004480)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFD3FF32).withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF001F3D).withValues(alpha: isDark ? 0.4 : 0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD3FF32).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD3FF32).withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle_fill_rounded,
                            size: 13, color: Color(0xFFD3FF32)),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            lesson.isActive ? context.tr('activeNow') : context.tr('todayLesson'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFD3FF32),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (lesson.scheduleDays.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      lesson.scheduleDays,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mainTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.5,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                height: 1.25,
              ),
            ),
            if (subtitleText != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitleText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (lesson.teacher.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_pin_rounded,
                      size: 16, color: Color(0xFFD3FF32)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "${context.tr('mentor')}: ${lesson.teacher}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (lessonTimeString.isNotEmpty || lesson.room.isNotEmpty || (lesson.branchName != null && lesson.branchName!.isNotEmpty)) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (lessonTimeString.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 14, color: Color(0xFFD3FF32)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                lessonTimeString,
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
                  if (lessonTimeString.isNotEmpty && (lesson.room.isNotEmpty || (lesson.branchName != null && lesson.branchName!.isNotEmpty)))
                    const SizedBox(width: 8),
                  if (lesson.room.isNotEmpty || (lesson.branchName != null && lesson.branchName!.isNotEmpty))
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.meeting_room_rounded,
                                size: 14, color: Color(0xFFD3FF32)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                lesson.room.isNotEmpty ? lesson.room : (lesson.branchName ?? context.tr('mainRoom')),
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsHeader(BuildContext context, bool isDark, ThemeData theme, List<TopicModel> allTopics) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            context.tr('topicsAndHomework'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<TopicStatus?>(
          initialValue: _activeStatusFilter,
          onSelected: (status) {
            AppHaptics.selection();
            setState(() => _activeStatusFilter = status);
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_list_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  _getStatusFilterLabel(context, _activeStatusFilter),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF001E36),
                  ),
                ),
              ],
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(value: null, child: Text(context.tr('all'))),
            PopupMenuItem(value: TopicStatus.done, child: Text(context.tr('topicDone'))),
            PopupMenuItem(value: TopicStatus.notDone, child: Text(context.tr('topicNotDone'))),
            PopupMenuItem(value: TopicStatus.notSubmitted, child: Text(context.tr('topicNotSubmitted'))),
            PopupMenuItem(value: TopicStatus.notGiven, child: Text(context.tr('topicNotGiven'))),
          ],
        ),
      ],
    );
  }

  Widget _buildTopicTile(TopicModel topic, bool isDark, ThemeData theme) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (topic.status) {
      case TopicStatus.done:
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_rounded;
        statusText = context.tr('topicDone');
        break;
      case TopicStatus.notDone:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.timelapse_rounded;
        statusText = context.tr('topicNotDone');
        break;
      case TopicStatus.notSubmitted:
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.error_outline_rounded;
        statusText = context.tr('topicNotSubmitted');
        break;
      case TopicStatus.notGiven:
        statusColor = const Color(0xFF64748B);
        statusIcon = Icons.lock_clock_rounded;
        statusText = context.tr('topicNotGiven');
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          AppHaptics.light();
          TopicDetailsSheet.show(
            context,
            topic,
            onSubmitted: _loadLessonsData,
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF001E36) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF002F52) : const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(statusIcon, color: statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3FF32).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.assignment_outlined, size: 11, color: Color(0xFF769B00)),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  context.tr('taskAvailable'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF769B00),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (topic.description.isNotEmpty)
                          Text(
                            topic.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 105),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTopics(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.search_off_rounded,
              size: 48,
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            context.tr('noTopicsFound'),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF001E36),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('noTopicsSub'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusFilterLabel(BuildContext context, TopicStatus? status) {
    switch (status) {
      case TopicStatus.done:
        return context.tr('topicDone');
      case TopicStatus.notDone:
        return context.tr('topicNotDone');
      case TopicStatus.notSubmitted:
        return context.tr('topicNotSubmitted');
      case TopicStatus.notGiven:
        return context.tr('topicNotGiven');
      case null:
        return context.tr('filter');
    }
  }
}

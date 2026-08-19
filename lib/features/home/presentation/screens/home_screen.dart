import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/section_header.dart';
import 'package:m_it_student_platform/core/widgets/student_avatar.dart';
import 'package:m_it_student_platform/features/home/data/repositories/mock_home_repository.dart';
import 'package:m_it_student_platform/features/home/domain/models/announcement_model.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/ai_mentor_in_progress_modal.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/all_announcements_modal.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/announcement_card.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/announcement_details_modal.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/featured_class_card.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/it_news_section.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/lab_booking_modal.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/mentor_chat_modal.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/stat_card.dart';
import 'package:m_it_student_platform/features/homework/presentation/widgets/homework_modal.dart';
import 'package:m_it_student_platform/features/lessons/data/repositories/mock_lessons_repository.dart';
import 'package:m_it_student_platform/features/lessons/presentation/widgets/lesson_card.dart';
import 'package:m_it_student_platform/features/lessons/presentation/widgets/lesson_details_sheet.dart';
import 'package:m_it_student_platform/features/payments/data/repositories/mock_payments_repository.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';
import 'package:m_it_student_platform/features/profile/presentation/widgets/student_id_card_modal.dart';
import 'package:m_it_student_platform/features/quiz/presentation/widgets/quiz_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateToTab});

  final ValueChanged<int>? onNavigateToTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _showAllAnnouncements(BuildContext context) {
    AppHaptics.light();
    AllAnnouncementsModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const featured = MockHomeRepository.featuredClass;
    const todayClasses = MockLessonsRepository.todayLessons;
    const payment = MockPaymentsRepository.paymentSummary;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            AppHaptics.light();
            await Future<void>.delayed(const Duration(milliseconds: 400));
          },
          child: ValueListenableBuilder<StudentProfile>(
            valueListenable: MockProfileRepository.studentNotifier,
            builder: (context, student, _) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  // 1. Student Header Row (Avatar on Left, Name in Middle, Bell on Right)
                  Row(
                    children: [
                      // Avatar on the Left (Tap to show Digital QR Pass)
                      GestureDetector(
                        onTap: () {
                          AppHaptics.selection();
                          StudentIdCardModal.show(context);
                        },
                        child: StudentAvatar(
                          size: 46,
                          avatarEmoji: student.resolvedAvatarEmoji,
                          gender: student.gender,
                          initials: student.initials,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Student Name & Group in the Middle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Text(
                                student.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            const SizedBox(height: 2),
                            Text(
                              student.courseName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Notification Bell Button on the Right
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.04,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.notifications_none_rounded,
                                size: 22,
                                color: theme.colorScheme.onSurface,
                              ),
                              onPressed: () => _showAllAnnouncements(context),
                            ),
                            Positioned(
                              right: 11,
                              top: 11,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentLime,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 2. Continuous Auto-Scrolling Compact Quick Services Carousel
                  _AutoScrollingQuickActions(
                    onShowAnnouncements: () => _showAllAnnouncements(context),
                  ),
                  const SizedBox(height: 16),

                  // 3. Today's Featured In-Person IT Class
                  FeaturedClassCard(
                    lesson: featured,
                    onViewDetails: () =>
                        LessonDetailsSheet.show(context, featured),
                  ),
                  const SizedBox(height: 22),

                  // 4. Quick Statistics Grid (2x2)
                  SectionHeader(
                    title: context.tr('academicOverview'),
                    subtitle: context.tr('academicOverviewSub'),
                  ),
                  const SizedBox(height: 12),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 114,
                        ),
                    children: [
                      StatCard(
                        title: context.tr('statTodayClasses'),
                        value: '${todayClasses.length}',
                        icon: Icons.school_rounded,
                        accentColor: AppColors.primary,
                        badgeText: context.tr('activeStatus'),
                        badgeColor: isDark
                            ? AppColors.primaryAccent
                            : AppColors.primary,
                        onTap: () => widget.onNavigateToTab?.call(1),
                      ),
                      StatCard(
                        title: context.tr('statAttendance'),
                        value: '${student.attendancePercentage}%',
                        icon: Icons.fact_check_outlined,
                        accentColor: AppColors.secondary,
                        badgeText: context.tr('attendanceTrend'),
                        badgeColor: AppColors.success,
                        onTap: () => widget.onNavigateToTab?.call(3),
                      ),
                      StatCard(
                        title: context.tr('statGpa'),
                        value: '${student.overallScore}%',
                        icon: Icons.grade_outlined,
                        accentColor: AppColors.accentPurple,
                        badgeText: context.tr('topRank'),
                        badgeColor: AppColors.accentPurple,
                        onTap: () => widget.onNavigateToTab?.call(3),
                      ),
                      StatCard(
                        title: context.tr('statRemaining'),
                        value: context.tr('monthlyFee'),
                        icon: Icons.account_balance_wallet_outlined,
                        accentColor: AppColors.accentAmber,
                        badgeText: payment.isPaid
                            ? context.tr('paid')
                            : context.tr('unpaid'),
                        badgeColor: payment.isPaid
                            ? AppColors.success
                            : AppColors.danger,
                        onTap: () => widget.onNavigateToTab?.call(2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // 5. Today's IT Schedule Section
                  SectionHeader(
                    title: context.tr('todaySchedule'),
                    subtitle: context.tr('todayScheduleSub'),
                    actionLabel: context.tr('seeAll'),
                    onAction: () => widget.onNavigateToTab?.call(1),
                  ),
                  const SizedBox(height: 12),
                  ...todayClasses.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LessonCard(
                        lesson: item,
                        onTap: () => LessonDetailsSheet.show(context, item),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),

                  // 6. IT Academy Announcements
                  SectionHeader(
                    title: context.tr('campusAnnouncements'),
                    subtitle: context.tr('campusAnnouncementsSub'),
                    actionLabel: context.tr('allNotices'),
                    onAction: () => _showAllAnnouncements(context),
                  ),
                  const SizedBox(height: 12),
                  ...MockHomeRepository.announcements.take(3).map((ann) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AnnouncementCard(
                        announcement: ann,
                        onTap: () => AnnouncementDetailsModal.show(
                          context,
                          ann,
                          onAction: () {
                            if (ann.type == AnnouncementType.payment) {
                              widget.onNavigateToTab?.call(2);
                            }
                          },
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 22),

                  // 7. IT Yangiliklari bo'limi (Rasmiy Manbalar)
                  const ItNewsSection(horizontalPadding: 0),
                  const SizedBox(height: 100),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AutoScrollingQuickActions extends StatefulWidget {
  const _AutoScrollingQuickActions({required this.onShowAnnouncements});

  final VoidCallback onShowAnnouncements;

  @override
  State<_AutoScrollingQuickActions> createState() =>
      _AutoScrollingQuickActionsState();
}

class _AutoScrollingQuickActionsState
    extends State<_AutoScrollingQuickActions> {
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  Timer? _resumeTimer;
  bool _isUserInteracting = false;

  final List<
    (_QuickItemData Function(BuildContext), void Function(BuildContext))
  >
  _itemBuilders = [
    (
      (ctx) => _QuickItemData(
        icon: Icons.psychology_rounded,
        label: ctx.tr('quickQuiz'),
        badge: ctx.tr('quickQuizBadge'),
        color: AppColors.accentAmber,
      ),
      (ctx) => QuizModal.show(ctx),
    ),
    (
      (ctx) => _QuickItemData(
        icon: Icons.auto_awesome_rounded,
        label: ctx.tr('quickAiMentor'),
        badge: ctx.tr('quickAiMentorBadge'),
        color: const Color(0xFF6366F1),
      ),
      (ctx) => AiMentorInProgressModal.show(ctx),
    ),
    (
      (ctx) => _QuickItemData(
        icon: Icons.qr_code_2_rounded,
        label: ctx.tr('quickQrPass'),
        badge: ctx.tr('quickQrPassBadge'),
        color: AppColors.primary,
      ),
      (ctx) => StudentIdCardModal.show(ctx),
    ),
    (
      (ctx) => _QuickItemData(
        icon: Icons.code_rounded,
        label: ctx.tr('quickHomework'),
        badge: ctx.tr('quickHomeworkBadge'),
        color: AppColors.accentPurple,
      ),
      (ctx) => HomeworkModal.show(ctx),
    ),
    (
      (ctx) => _QuickItemData(
        icon: Icons.meeting_room_rounded,
        label: ctx.tr('quickLabBook'),
        badge: ctx.tr('quickLabBookBadge'),
        color: AppColors.secondary,
      ),
      (ctx) => LabBookingModal.show(ctx),
    ),
    (
      (ctx) => _QuickItemData(
        icon: Icons.support_agent_rounded,
        label: ctx.tr('quickLiveMentor'),
        badge: ctx.tr('quickLiveMentorBadge'),
        color: AppColors.success,
      ),
      (ctx) => MentorChatModal.show(ctx),
    ),
    (
      (ctx) => _QuickItemData(
        icon: Icons.rocket_launch_rounded,
        label: ctx.tr('quickHackathon'),
        badge: ctx.tr('quickHackathonBadge'),
        color: const Color(0xFFEC4899),
      ),
      (ctx) => QuizModal.show(ctx),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    // Skip continuous infinite timer during automated test runs
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return;
    }

    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 35), (
      timer,
    ) {
      if (!mounted || !_scrollController.hasClients || _isUserInteracting) {
        return;
      }
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      if (currentScroll >= maxScroll - 2) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(currentScroll + 1.0);
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _resumeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const repeatCount = 200;

    return RepaintBoundary(
      child: SizedBox(
        height: 48,
        child: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (notification.direction != ScrollDirection.idle) {
              _isUserInteracting = true;
              _resumeTimer?.cancel();
            } else {
              _resumeTimer?.cancel();
              _resumeTimer = Timer(const Duration(seconds: 2), () {
                if (mounted) {
                  _isUserInteracting = false;
                }
              });
            }
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _itemBuilders.length * repeatCount,
            itemBuilder: (context, index) {
              final itemIndex = index % _itemBuilders.length;
              final item = _itemBuilders[itemIndex].$1(context);
              final onTapAction = _itemBuilders[itemIndex].$2;
              final effectiveColor = (isDark &&
                      (item.color == AppColors.primary ||
                          item.color == AppColors.brandNavy ||
                          item.color == const Color(0xFF00213D)))
                  ? AppColors.accentLime
                  : item.color;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTapAction(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceSecondary
                            : AppColors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? theme.colorScheme.outline
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.8,
                                ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: effectiveColor.withValues(
                                alpha: isDark ? 0.25 : 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(item.icon, color: effectiveColor, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: effectiveColor.withValues(
                                alpha: isDark ? 0.2 : 0.12,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.badge,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: effectiveColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuickItemData {
  const _QuickItemData({
    required this.icon,
    required this.label,
    required this.badge,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String badge;
  final Color color;
}

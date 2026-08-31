import 'dart:async';
import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/routes/app_routes.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/section_header.dart';
import 'package:m_it_student_platform/core/widgets/student_avatar.dart';
import 'package:m_it_student_platform/features/profile/presentation/widgets/edit_profile_modal.dart';
import 'package:m_it_student_platform/features/home/data/repositories/mock_home_repository.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/featured_class_card.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/stat_card.dart';
import 'package:m_it_student_platform/features/lessons/data/repositories/mock_lessons_repository.dart';
import 'package:m_it_student_platform/features/lessons/presentation/widgets/lesson_details_sheet.dart';
import 'package:m_it_student_platform/features/payments/data/repositories/mock_payments_repository.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:m_it_student_platform/features/profile/domain/models/student_model.dart';
import 'package:m_it_student_platform/core/storage/app_cache_service.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/features/home/domain/repositories/home_repository.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/gamification_modal.dart';
import 'package:m_it_student_platform/features/home/presentation/widgets/resources_library_modal.dart';
import 'package:m_it_student_platform/features/lessons/data/repositories/lessons_repository_impl.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';
import 'package:m_it_student_platform/features/lessons/domain/repositories/lessons_repository.dart';
import 'package:m_it_student_platform/features/lessons/presentation/widgets/lesson_card.dart';
import 'package:m_it_student_platform/core/widgets/shimmer_loading.dart';
import 'package:m_it_student_platform/features/payments/domain/entities/payment.dart';
import 'package:m_it_student_platform/features/payments/domain/repositories/payments_repository.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:m_it_student_platform/features/profile/domain/repositories/profile_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onNavigateToTab});

  final ValueChanged<int>? onNavigateToTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late final HomeRepository _homeRepo;
  late final LessonsRepository _lessonsRepo;
  late final PaymentsRepository _paymentsRepo;

  Lesson _featured = MockHomeRepository.featuredClass;
  List<Lesson> _todayClasses = MockLessonsRepository.todayLessons;
  PaymentSummary _payment = MockPaymentsRepository.paymentSummary;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _homeRepo = sl<HomeRepository>();
    _lessonsRepo = sl.isRegistered<LessonsRepository>()
        ? sl<LessonsRepository>()
        : LessonsRepositoryImpl();
    _paymentsRepo = sl<PaymentsRepository>();

    // Instant offline-cache hydration so screen is never blank on entry
    final cachedFeatured = AppCacheService.getCache(AppCacheService.keyFeaturedClass);
    if (cachedFeatured is Map<String, dynamic>) {
      _featured = Lesson.fromJson(cachedFeatured);
      _isLoading = false;
    }
    final cachedLessons = AppCacheService.getCache(AppCacheService.keyLessons);
    if (cachedLessons is List) {
      final list = cachedLessons.whereType<Map<String, dynamic>>().map(Lesson.fromJson).toList();
      if (list.isNotEmpty) _todayClasses = list;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadHomeData();
    });
  }

  Future<void> _loadHomeData() async {
    if (!mounted) return;
    if (_todayClasses.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      await Future.wait([
        _homeRepo
            .getFeaturedClass()
            .then((featured) {
          if (mounted) setState(() => _featured = featured);
        }).catchError((_) {}),
        _lessonsRepo
            .getTodayLessons()
            .then((today) {
          if (mounted && today.isNotEmpty) setState(() => _todayClasses = today);
        }).catchError((_) {}),
        _paymentsRepo
            .getPaymentSummary()
            .then((paymentResult) {
          paymentResult.when(
            success: (data) {
              if (mounted) setState(() => _payment = data);
            },
            failure: (_) {},
          );
        }).catchError((_) {}),
        (sl.isRegistered<ProfileRepository>()
                ? sl<ProfileRepository>()
                : ProfileRepositoryImpl())
            .getStudentProfile()
            .catchError((_) => MockProfileRepository.currentStudent),
      ]);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatMonthlyFee(
    String? featuredFee,
    String? studentPayment,
    double monthlyRate,
    String currency,
  ) {
    if (featuredFee != null && featuredFee.isNotEmpty) {
      return _formatAmountWithSpaces(featuredFee, currency);
    }
    if (studentPayment != null && studentPayment.isNotEmpty) {
      return _formatAmountWithSpaces(studentPayment, currency);
    }
    if (monthlyRate > 0) {
      return _formatAmountWithSpaces(monthlyRate, currency);
    }
    return '500 000 $currency';
  }

  static String _formatAmountWithSpaces(dynamic value, [String currency = "so'm"]) {
    if (value == null) return '500 000 $currency';
    if (value is num) {
      if (value <= 0) return '500 000 $currency';
      final intVal = value.toInt();
      final formatted = intVal.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]} ',
      );
      return '$formatted $currency';
    }
    final str = value.toString().trim();
    if (str.isEmpty) return '500 000 $currency';
    final digits = str.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return str;
    final numVal = int.tryParse(digits) ?? 500000;
    final formatted = numVal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$formatted $currency';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final featured = _featured;
    final todayClasses = _todayClasses;
    final payment = _payment;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadHomeData,
          color: const Color(0xFFD3FF32),
          child: ValueListenableBuilder<StudentProfile>(
            valueListenable: MockProfileRepository.studentNotifier,
            builder: (context, student, _) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
                children: [
                  // 1. Student Avatar + Name + Notification Bell Header (Har doim ochiq, Shimmersiz)
                  Row(
                    children: [
                      // Avatar on the Left
                      GestureDetector(
                        onTap: () {
                          AppHaptics.selection();
                          EditProfileModal.show(context, student);
                        },
                        child: StudentAvatar(
                          size: 46,
                          avatarEmoji: student.resolvedAvatarEmoji,
                          gender: student.gender,
                          initials: student.initials,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Student Name in the Middle
                      Expanded(
                        child: Text(
                          student.fullName.isNotEmpty
                              ? student.fullName
                              : context.tr('student'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19.5,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceSecondary
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
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
                              onPressed: () {
                                AppHaptics.light();
                                Navigator.of(context).pushNamed(AppRoutes.notifications);
                              },
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

                  // 2. Quick Feature Horizontal Scroller (Ariza, Resurslar, Gamifikatsiya)
                  _buildQuickFeatureScroller(context, isDark, student),
                  const SizedBox(height: 16),

                  // 3. Featured Active Class Card (Asosiy card - yuklanayotganda shimmer)
                  if (_isLoading)
                    const ShimmerCardSkeleton(height: 170)
                  else () {
                    var effectiveFeatured = featured;
                    if (effectiveFeatured.room.isEmpty) {
                      effectiveFeatured = effectiveFeatured.copyWith(
                        room: student.room.isNotEmpty ? student.room : '3-xona',
                      );
                    }
                    if (effectiveFeatured.startTime.isEmpty && student.classTime.isNotEmpty) {
                      final parts = student.classTime.split(RegExp(r'\s*[–-]\s*'));
                      if (parts.isNotEmpty) {
                        effectiveFeatured = effectiveFeatured.copyWith(
                          startTime: parts[0].trim(),
                          endTime: parts.length > 1 ? parts[1].trim() : '',
                        );
                      }
                    }
                    return RepaintBoundary(
                      child: FeaturedClassCard(
                        lesson: effectiveFeatured,
                        onViewDetails: () =>
                            LessonDetailsSheet.show(context, effectiveFeatured),
                      ),
                    );
                  }(),
                  const SizedBox(height: 22),

                  // 4. Quick Statistics Grid (4 talik card - yuklanayotganda shimmer)
                  SectionHeader(
                    title: context.tr('academicOverview'),
                    subtitle: context.tr('academicOverviewSub'),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const ShimmerStatGridSkeleton()
                  else
                    RepaintBoundary(
                      child: GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              mainAxisExtent: 120,
                            ),
                        children: [
                        StatCard(
                          title: context.tr('statTodayClasses'),
                          value: '${todayClasses.length}',
                          icon: Icons.school_rounded,
                          accentColor: AppColors.primary,
                          badgeText: todayClasses.isNotEmpty
                              ? context.tr('activeStatus')
                              : (student.group.isNotEmpty ? student.group : context.tr('activeStatus')),
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
                          onTap: () {
                            AppHaptics.selection();
                            Navigator.of(context).pushNamed(AppRoutes.attendance);
                          },
                        ),
                        StatCard(
                          title: context.tr('statGpa'),
                          value: '${student.overallScore}%',
                          icon: Icons.grade_outlined,
                          accentColor: AppColors.accentPurple,
                          badgeText: context.tr('topRank'),
                          badgeColor: AppColors.accentPurple,
                          onTap: () {
                            AppHaptics.selection();
                            Navigator.of(context).pushNamed(AppRoutes.grades);
                          },
                        ),
                        StatCard(
                          title: context.tr('statMonthlyTuition'),
                          value: _formatMonthlyFee(
                            featured.monthlyFee,
                            student.monthlyPayment,
                            payment.monthlyRate,
                            context.tr('currencySom'),
                          ),
                          icon: Icons.account_balance_wallet_outlined,
                          accentColor: const Color(0xFF10B981),
                          badgeText: context.tr('tuitionCycle'),
                          badgeColor: const Color(0xFF10B981),
                          onTap: () => widget.onNavigateToTab?.call(2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // 5. Today's Lessons (Bugungi darslar - Faqat 1 ta dars, Barchasi bosilganda darslar tabiga o'tadi)
                  SectionHeader(
                    title: context.tr('todayClasses'),
                    subtitle: student.group.isNotEmpty ? student.group : 'Back end 05',
                    actionLabel: context.tr('seeAll'),
                    onAction: () => widget.onNavigateToTab?.call(1),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const ShimmerTopicListSkeleton(itemCount: 1)
                  else () {
                    final rawLesson = todayClasses.isNotEmpty ? todayClasses.first : featured;
                    final effectiveLesson = (rawLesson.room.isNotEmpty || student.room.isEmpty)
                        ? rawLesson
                        : rawLesson.copyWith(room: student.room);
                    return LessonCard(
                      lesson: effectiveLesson,
                      onTap: () => LessonDetailsSheet.show(
                        context,
                        effectiveLesson,
                      ),
                    );
                  }(),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickFeatureScroller(
    BuildContext context,
    bool isDark,
    StudentProfile student,
  ) {
    final items = [
      _QuickItemData(
        icon: Icons.edit_document,
        label: 'Ariza',
        badge: 'Sababli',
        accentColor: isDark ? const Color(0xFFD3FF32) : const Color(0xFF16A34A),
        lightBadgeTextColor: const Color(0xFF15803D),
        onTap: () {
          AppHaptics.selection();
          Navigator.of(context).pushNamed(AppRoutes.complaint);
        },
      ),
      _QuickItemData(
        icon: Icons.folder_zip_rounded,
        label: 'Resurslar',
        badge: 'PDF/Zip',
        accentColor: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
        lightBadgeTextColor: const Color(0xFF075985),
        onTap: () => ResourcesLibraryModal.show(context),
      ),
      _QuickItemData(
        icon: Icons.emoji_events_rounded,
        label: 'Gamifikatsiya',
        badge: '120 XP',
        accentColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
        lightBadgeTextColor: const Color(0xFF92400E),
        onTap: () => GamificationModal.show(context),
      ),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                AppHaptics.selection();
                item.onTap();
              },
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceSecondary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.25)
                          : const Color(0xFF64748B).withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: item.accentColor.withValues(
                          alpha: isDark ? 0.20 : 0.12,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: item.accentColor, size: 15),
                    ),
                    const SizedBox(width: 7),

                    // Title Text
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: item.accentColor.withValues(
                          alpha: isDark ? 0.20 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: item.accentColor.withValues(
                            alpha: isDark ? 0.35 : 0.25,
                          ),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        item.badge,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : item.lightBadgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuickItemData {
  const _QuickItemData({
    required this.icon,
    required this.label,
    required this.badge,
    required this.accentColor,
    required this.lightBadgeTextColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String badge;
  final Color accentColor;
  final Color lightBadgeTextColor;
  final VoidCallback onTap;
}

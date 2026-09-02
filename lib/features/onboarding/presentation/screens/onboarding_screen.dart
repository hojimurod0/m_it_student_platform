import 'dart:async';
import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/routes/app_routes.dart';
import 'package:m_it_student_platform/core/state/app_scope.dart';
import 'package:m_it_student_platform/core/state/app_settings.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _floatController;
  late final Animation<double> _scaleAnimation;
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  // Signature M-IT Brand Colors
  static const Color _limeColor = Color(0xFFD3FF32);
  static const Color _navyDark = Color(0xFF001E36);
  static const Color _navyCard = Color(0xFF002847);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Subtle breathing/floating scale animation
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(
        parent: _floatController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Auto-slide every 3 seconds
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_pageController.hasClients) return;
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
        );
      } else {
        // Loop back or stay
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _resetAutoSlideTimer() {
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    _autoSlideTimer?.cancel();
    AppHaptics.medium();
    await LocalStorageService.setCompletedOnboarding(true);
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  void _nextPage() {
    _resetAutoSlideTimer();
    AppHaptics.selection();
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lang = context.appSettings.language;
    final slides = _getSlides(lang);

    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00172B),
              Color(0xFF001120),
              Color(0xFF000B15),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4F9F2),
              Color(0xFFEAF4E8),
              Color(0xFFF8FCF7),
            ],
          );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF001120) : const Color(0xFFF4F9F2),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Bar with "O'tkazib yuborish" (Skip)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: SizedBox(
                  height: 42,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand Mini Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _limeColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _limeColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'M-IT UNO',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: Color(0xFF6B8B00),
                          ),
                        ),
                      ),

                      // Skip Button
                      TextButton(
                        onPressed: _finishOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.7)
                              : _navyDark.withValues(alpha: 0.75),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                        ),
                        child: Text(
                          _getSkipText(lang),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. PageView Content (Taking ~50% for image and rest for text)
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    _resetAutoSlideTimer();
                  },
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return _buildSlideItem(
                      slide: slide,
                      isDark: isDark,
                    );
                  },
                ),
              ),

              // 3. Bottom Action Row (Dots on Left + Large > Button in Right Corner)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Dot Indicators with Progress Feel
                    Row(
                      children: List.generate(3, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.only(right: 7),
                          width: isActive ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? _limeColor
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : const Color(0xFFCDE8BC)),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: _limeColor.withValues(alpha: 0.6),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      }),
                    ),

                    // Right Corner Action Button (Large Lime Circle with >)
                    InkWell(
                      onTap: _nextPage,
                      borderRadius: BorderRadius.circular(32),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: _currentPage == 2 ? 140 : 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _limeColor,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: _limeColor.withValues(alpha: 0.45),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _currentPage == 2
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getStartText(lang),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: _navyDark,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 20,
                                      color: _navyDark,
                                    ),
                                  ],
                                )
                              : const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 28,
                                  color: _navyDark,
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
      ),
    );
  }

  Widget _buildSlideItem({
    required _OnboardingData slide,
    required bool isDark,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final imageHeight = (screenHeight * 0.48).clamp(160.0, 310.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Large Image Section
              SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: double.infinity,
                          height: imageHeight,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: isDark ? _navyCard : Colors.white,
                            border: Border.all(
                              color: _limeColor.withValues(alpha: isDark ? 0.25 : 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _limeColor.withValues(alpha: isDark ? 0.12 : 0.18),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: _navyDark.withValues(alpha: isDark ? 0.4 : 0.08),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Image.asset(
                              slide.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.school_rounded,
                                    size: 72,
                                    color: _limeColor,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title Text Below Image
              Text(
                slide.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : _navyDark,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle Text
              Text(
                slide.description,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.72)
                      : const Color(0xFF4A5D6E),
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_OnboardingData> _getSlides(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ru:
        return const [
          _OnboardingData(
            title: "Добро пожаловать в M-IT UNO",
            description:
                "Современный учебный IT-центр — всё для студентов и родителей в одном удобном приложении.",
            imagePath: 'assets/images/onboarding_1.jpg',
          ),
          _OnboardingData(
            title: "Удобный учебный процесс для студентов",
            description:
                "Следите за расписанием уроков, домашними заданиями и личными результатами в одном месте.",
            imagePath: 'assets/images/onboarding_2.jpg',
          ),
          _OnboardingData(
            title: "Полный контроль для родителей",
            description:
                "Следите за посещаемостью и достижениями вашего ребенка, оставайтесь на связи с преподавателями.",
            imagePath: 'assets/images/onboarding_3.jpg',
          ),
        ];
      case AppLanguage.en:
        return const [
          _OnboardingData(
            title: "Welcome to M-IT UNO",
            description:
                "Modern IT learning academy — everything for students and parents in one convenient app.",
            imagePath: 'assets/images/onboarding_1.jpg',
          ),
          _OnboardingData(
            title: "Convenient Learning for Students",
            description:
                "Track class schedules, homework assignments, and personal progress in one place.",
            imagePath: 'assets/images/onboarding_2.jpg',
          ),
          _OnboardingData(
            title: "Full Oversight for Parents",
            description:
                "Monitor attendance and achievements of your child, stay in touch with instructors.",
            imagePath: 'assets/images/onboarding_3.jpg',
          ),
        ];
      case AppLanguage.uz:
        return const [
          _OnboardingData(
            title: "M-IT UNO ga xush kelibsiz",
            description:
                "Zamonaviy IT ta'lim markazi — talabalar va ota-onalar uchun bitta qulay ilovada.",
            imagePath: 'assets/images/onboarding_1.jpg',
          ),
          _OnboardingData(
            title: "Talabalar uchun qulay o'quv jarayoni",
            description:
                "Darslar jadvali, uy vazifalari va shaxsiy natijalaringizni bir joyda kuzatib boring.",
            imagePath: 'assets/images/onboarding_2.jpg',
          ),
          _OnboardingData(
            title: "Ota-onalar uchun to'liq nazorat",
            description:
                "Farzandingizning davomati va yutuqlarini kuzating, o'qituvchilar bilan aloqada bo'ling.",
            imagePath: 'assets/images/onboarding_3.jpg',
          ),
        ];
    }
  }

  String _getSkipText(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.uz:
        return "O'tkazib yuborish";
      case AppLanguage.ru:
        return "Пропустить";
      case AppLanguage.en:
        return "Skip";
    }
  }

  String _getStartText(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.uz:
        return "Boshlash";
      case AppLanguage.ru:
        return "Начать";
      case AppLanguage.en:
        return "Start";
    }
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final String imagePath;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

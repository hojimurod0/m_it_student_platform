import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/routes/app_routes.dart';
import 'package:m_it_student_platform/core/state/app_scope.dart';
import 'package:m_it_student_platform/core/state/app_settings.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AppLanguage _selectedLanguage;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = LocalStorageService.getLanguage();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onLanguageSelected(AppLanguage lang) {
    AppHaptics.selection();
    setState(() => _selectedLanguage = lang);
    context.appSettings.setLanguage(lang);
  }

  Future<void> _onContinue() async {
    AppHaptics.medium();
    await LocalStorageService.setSelectedLanguage(true);
    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final languages = [
      const _LanguageItem(
        language: AppLanguage.uz,
        title: "O'zbek tili",
        subtitle: "Lotin yozuvida",
        flag: "🇺🇿",
      ),
      const _LanguageItem(
        language: AppLanguage.ru,
        title: "Русский язык",
        subtitle: "Интерфейс на русском",
        flag: "🇷🇺",
      ),
      const _LanguageItem(
        language: AppLanguage.en,
        title: "English",
        subtitle: "English interface",
        flag: "🇬🇧",
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top & Content Area
                          Column(
                            children: [
                              const SizedBox(height: 16),

                              // Minimalist App Logo Badge
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceSecondary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.darkCardBorder
                                        : AppColors.cardBorder,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: isDark ? 0.25 : 0.05,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.school_rounded,
                                        size: 36,
                                        color: isDark
                                            ? AppColors.primaryAccent
                                            : AppColors.primary,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              Text(
                                _getTitleText(_selectedLanguage),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Subtitle
                              Text(
                                _getSubtitleText(_selectedLanguage),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Language Cards List
                              ...languages.map((item) {
                                final isSelected =
                                    item.language == _selectedLanguage;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildLanguageCard(
                                    item: item,
                                    isSelected: isSelected,
                                    isDark: isDark,
                                  ),
                                );
                              }),
                            ],
                          ),

                          // Bottom Action Area
                          Column(
                            children: [
                              const SizedBox(height: 24),

                              // Continue CTA Button
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _onContinue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? AppColors.primaryAccent
                                        : AppColors.primary,
                                    foregroundColor: isDark
                                        ? AppColors.primaryDark
                                        : Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _getButtonText(_selectedLanguage),
                                        style: TextStyle(
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.primaryDark
                                              : Colors.white,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                        color: isDark
                                            ? AppColors.primaryDark
                                            : Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Helpful Info Note
                              Text(
                                _getHintText(_selectedLanguage),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required _LanguageItem item,
    required bool isSelected,
    required bool isDark,
  }) {
    final borderColor = isSelected
        ? (isDark ? AppColors.primaryAccent : AppColors.primary)
        : (isDark ? AppColors.darkCardBorder : AppColors.cardBorder);

    final cardBg = isSelected
        ? (isDark
            ? AppColors.primaryAccent.withValues(alpha: 0.12)
            : AppColors.primarySurface)
        : (isDark ? AppColors.darkSurface : Colors.white);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onLanguageSelected(item.language),
        borderRadius: BorderRadius.circular(18),
        splashColor: isDark
            ? AppColors.primaryAccent.withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.06),
        highlightColor: isDark
            ? AppColors.primaryAccent.withValues(alpha: 0.04)
            : AppColors.primary.withValues(alpha: 0.03),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (isDark
                              ? AppColors.primaryAccent
                              : AppColors.primary)
                          .withValues(alpha: isDark ? 0.15 : 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Flag Container
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceSecondary
                      : AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkCardBorder
                        : AppColors.cardBorder.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Minimalist Selection Indicator (Radio / Check)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? (isDark ? AppColors.primaryAccent : AppColors.primary)
                        : (isDark
                            ? AppColors.darkTextMuted.withValues(alpha: 0.5)
                            : AppColors.textMuted.withValues(alpha: 0.5)),
                    width: isSelected ? 0 : 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: isDark ? AppColors.primaryDark : Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitleText(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.uz:
        return "Tilni tanlang";
      case AppLanguage.ru:
        return "Выберите язык";
      case AppLanguage.en:
        return "Choose Language";
    }
  }

  String _getSubtitleText(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.uz:
        return "Ilovadan qulay foydalanish uchun tilingizni tanlang";
      case AppLanguage.ru:
        return "Выберите удобный язык для работы с приложением";
      case AppLanguage.en:
        return "Select your preferred language to continue";
    }
  }

  String _getButtonText(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.uz:
        return "Davom etish";
      case AppLanguage.ru:
        return "Продолжить";
      case AppLanguage.en:
        return "Continue";
    }
  }

  String _getHintText(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.uz:
        return "Tilni keyinroq profil sozlamalaridan o'zgartirishingiz mumkin";
      case AppLanguage.ru:
        return "Язык можно изменить позже в настройках профиля";
      case AppLanguage.en:
        return "You can change the language later in profile settings";
    }
  }
}

class _LanguageItem {
  final AppLanguage language;
  final String title;
  final String subtitle;
  final String flag;

  const _LanguageItem({
    required this.language,
    required this.title,
    required this.subtitle,
    required this.flag,
  });
}

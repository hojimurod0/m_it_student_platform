import 'dart:async';
import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/constants/app_colors.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/core/routes/app_routes.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/core/widgets/app_logo.dart';
import 'package:m_it_student_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:m_it_student_platform/features/auth/data/repositories/auth_repository_impl.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    _timer = Timer(const Duration(milliseconds: 1800), () async {
      if (!mounted) return;

      final token = LocalStorageService.getAuthToken();
      final isLoggedIn = LocalStorageService.isLoggedIn();

      String targetRoute;
      if (isLoggedIn && token != null && token.isNotEmpty) {
        if (!AppConfig.useMockData) {
          try {
            final authRepo = sl.isRegistered<AuthRepository>()
                ? sl<AuthRepository>()
                : AuthRepositoryImpl();
            final user = await authRepo.restoreSession();
            if (user != null) {
              targetRoute = AppRoutes.dashboard;
            } else {
              targetRoute = AppRoutes.login;
            }
          } catch (_) {
            targetRoute = AppRoutes.login;
          }
        } else {
          targetRoute = AppRoutes.dashboard;
        }
      } else if (!LocalStorageService.hasSelectedLanguage()) {
        targetRoute = AppRoutes.languageSelection;
      } else if (!LocalStorageService.hasCompletedOnboarding()) {
        targetRoute = AppRoutes.onboarding;
      } else {
        targetRoute = AppRoutes.login;
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(targetRoute);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  // Subtle top ambient circle
                  Positioned(
                    top: -60,
                    right: -60,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),

                  // Center Content (Official M-IT Logo, Title, Tagline)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: const AppLogo(
                            size: 130,
                            isLight: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                context.tr('splashTitle'),
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.8,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  context.tr('splashTagline'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom subtle loader & connection badge
                  Positioned(
                    bottom: 36,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            context.tr('splashStatus'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

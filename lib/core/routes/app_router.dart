import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/routes/app_routes.dart';
import 'package:m_it_student_platform/core/routes/not_found_screen.dart';
import 'package:m_it_student_platform/features/auth/presentation/screens/login_screen.dart';
import 'package:m_it_student_platform/features/lessons/presentation/screens/lessons_screen.dart';
import 'package:m_it_student_platform/features/navigation/presentation/main_shell.dart';
import 'package:m_it_student_platform/features/payments/presentation/screens/payments_screen.dart';
import 'package:m_it_student_platform/features/profile/presentation/screens/profile_screen.dart';
import 'package:m_it_student_platform/features/splash/presentation/splash_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildPageRoute(
          const SplashScreen(),
          settings,
        );

      case AppRoutes.login:
        return _buildPageRoute(
          const LoginScreen(),
          settings,
        );

      case AppRoutes.dashboard:
        return _buildPageRoute(
          const MainShell(),
          settings,
        );

      case AppRoutes.lessons:
        return _buildPageRoute(
          const LessonsScreen(),
          settings,
        );

      case AppRoutes.payments:
        return _buildPageRoute(
          const PaymentsScreen(),
          settings,
        );

      case AppRoutes.profile:
        return _buildPageRoute(
          const ProfileScreen(),
          settings,
        );

      default:
        return _buildPageRoute(
          const NotFoundScreen(),
          settings,
        );
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _buildPageRoute(
      const NotFoundScreen(),
      settings,
    );
  }

  static PageRouteBuilder<dynamic> _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.03);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 260),
    );
  }
}

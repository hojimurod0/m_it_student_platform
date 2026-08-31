import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/routes/app_routes.dart';
import 'package:m_it_student_platform/core/routes/not_found_screen.dart';
import 'package:m_it_student_platform/features/announcements/presentation/bloc/announcements_bloc.dart';
import 'package:m_it_student_platform/features/announcements/presentation/screens/announcements_screen.dart';
import 'package:m_it_student_platform/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:m_it_student_platform/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:m_it_student_platform/features/auth/presentation/screens/login_screen.dart';
import 'package:m_it_student_platform/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:m_it_student_platform/features/chat/presentation/screens/chat_screen.dart';
import 'package:m_it_student_platform/features/complaints/presentation/screens/complaint_screen.dart';
import 'package:m_it_student_platform/features/grades/presentation/bloc/grades_bloc.dart';
import 'package:m_it_student_platform/features/grades/presentation/screens/grades_screen.dart';
import 'package:m_it_student_platform/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:m_it_student_platform/features/lessons/presentation/screens/lessons_screen.dart';
import 'package:m_it_student_platform/features/navigation/presentation/main_shell.dart';
import 'package:m_it_student_platform/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:m_it_student_platform/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:m_it_student_platform/features/onboarding/presentation/screens/language_selection_screen.dart';
import 'package:m_it_student_platform/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:m_it_student_platform/features/payments/presentation/screens/payments_screen.dart';
import 'package:m_it_student_platform/features/profile/presentation/screens/profile_screen.dart';
import 'package:m_it_student_platform/features/reviews/presentation/screens/review_screen.dart';
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

      case AppRoutes.languageSelection:
        return _buildPageRoute(
          const LanguageSelectionScreen(),
          settings,
        );

      case AppRoutes.onboarding:
        return _buildPageRoute(
          const OnboardingScreen(),
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

      // ── Yangi feature routes ────────────────────────────────────────────
      case AppRoutes.grades:
        return _buildPageRoute(
          BlocProvider(
            create: (_) => sl<GradesBloc>(),
            child: const GradesScreen(),
          ),
          settings,
        );

      case AppRoutes.attendance:
        return _buildPageRoute(
          BlocProvider(
            create: (_) => sl<AttendanceBloc>(),
            child: const AttendanceScreen(),
          ),
          settings,
        );

      case AppRoutes.announcements:
        return _buildPageRoute(
          BlocProvider(
            create: (_) => sl<AnnouncementsBloc>(),
            child: const AnnouncementsScreen(),
          ),
          settings,
        );

      case AppRoutes.notifications:
        return _buildPageRoute(
          BlocProvider(
            create: (_) => sl<NotificationsBloc>(),
            child: const NotificationsScreen(),
          ),
          settings,
        );

      case AppRoutes.leaderboard:
        // arguments: {'groupId': String, 'myStudentId': String?}
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _buildPageRoute(
          LeaderboardScreen(
            groupId: (args['groupId'] ?? '').toString(),
            myStudentId: args['myStudentId']?.toString(),
          ),
          settings,
        );

      case AppRoutes.chat:
        // arguments: {'groupId': String, 'groupName': String, 'myUserId': String?}
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _buildPageRoute(
          BlocProvider(
            create: (_) => sl<ChatBloc>(),
            child: ChatScreen(
              groupId: (args['groupId'] ?? '').toString(),
              groupName: (args['groupName'] ?? 'Guruh chati').toString(),
              myUserId: args['myUserId']?.toString(),
            ),
          ),
          settings,
        );

      case AppRoutes.review:
        // arguments: {'mentorId': String?, 'mentorName': String?}
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _buildPageRoute(
          ReviewScreen(
            mentorId: args['mentorId']?.toString(),
            mentorName: args['mentorName']?.toString(),
          ),
          settings,
        );

      case AppRoutes.complaint:
        return _buildPageRoute(
          const ComplaintScreen(),
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

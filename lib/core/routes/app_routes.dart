/// Centralized route constants for type-safe routing.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String languageSelection = '/language-selection';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String lessons = '/lessons';
  static const String payments = '/payments';
  static const String profile = '/profile';
  static const String notFound = '/404';

  // ── Yangi feature routes ────────────────────────────────────────────────
  static const String grades        = '/grades';
  static const String attendance    = '/attendance';
  static const String announcements = '/announcements';
  static const String notifications = '/notifications';
  static const String leaderboard   = '/leaderboard';
  static const String chat          = '/chat';
  static const String review        = '/review';
  static const String complaint     = '/complaint';
}

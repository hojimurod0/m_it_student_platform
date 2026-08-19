enum AppEnvironment {
  development,
  staging,
  production,
}

class AppConfig {
  AppConfig._();

  static const AppEnvironment environment = AppEnvironment.development;

  /// Base API URL for backend integration
  static const String baseUrl = 'https://api.m-it.uz/api/v1';

  /// Toggle between Mock repositories and Real API backend
  /// Set to `false` once backend endpoints are live
  static const bool useMockData = true;

  /// Network request timeout
  static const Duration requestTimeout = Duration(seconds: 15);

  /// API Endpoints registry for easy backend connection
  static const String authLogin = '/auth/login';
  static const String authLogout = '/auth/logout';
  static const String authProfile = '/auth/me';
  static const String studentSchedule = '/student/schedule/today';
  static const String studentStats = '/student/stats';
  static const String studentLessons = '/student/lessons';
  static const String studentHomework = '/student/homework';
  static const String studentPayments = '/student/payments';
  static const String announcements = '/announcements';
  static const String itNews = '/news';
  static const String quizQuestions = '/quiz/questions';
}

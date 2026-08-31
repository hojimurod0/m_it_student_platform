enum AppEnvironment {
  development,
  staging,
  production,
}

class AppConfig {
  AppConfig._();

  static const AppEnvironment environment = AppEnvironment.production;

  /// Base API URL for JarvisX CRM & ERP backend
  static const String baseUrl = 'https://m-it-academy.jarvisx.uz/api/v1';

  /// Toggle between Mock repositories and Real API backend.
  /// Set to `false` for live backend data.
  static const bool useMockData = false;

  /// Network request timeout (15s for mobile connections and cold starts)
  static const Duration requestTimeout = Duration(seconds: 15);

  // ─── 1. Auth API ──────────────────────────────────────────────────────────
  static const String authLogin = '/auth/login/';
  static const String authLogout = '/auth/logout/';
  static const String authMe = '/auth/me/';
  static const String authChangePassword = '/auth/change-password/';
  static const String authFcmToken = '/auth/fcm-token/';

  // ─── 2. Student Portal (/portal/student/...) ──────────────────────────────
  static const String portalStudentProfile = '/portal/student/profile/';
  static const String portalStudentProgress = '/portal/student/progress/';
  static const String portalStudentGroups = '/portal/student/my-groups/';
  static const String portalStudentSchedule = '/portal/student/my-schedule/';
  static const String portalStudentAttendance = '/portal/student/my-attendance/';
  static const String portalStudentPayments = '/portal/student/my-payments/';
  static const String portalStudentLessons = '/portal/student/my-lessons/';
  static const String portalStudentHomeworks = '/portal/student/my-homeworks/';
  static String portalStudentHomeworkSubmit(String homeworkId) =>
      '/portal/student/my-homeworks/$homeworkId/submit/';
  static const String portalStudentGrades = '/portal/student/my-grades/';
  static const String portalStudentComplaints = '/portal/student/complaints/';

  // ─── 3. Mentor Portal (/portal/mentor/...) ───────────────────────────────
  static const String portalMentorGroups = '/portal/mentor/my-groups/';

  // ─── 4. LMS Tizimi (/lms/...) ────────────────────────────────────────────
  /// Darslar va Mavzular ro'yxati: GET /lms/lessons/ (masalan: ?group=1)
  static const String lmsLessons = '/lms/lessons/';

  /// Muayyan dars tafsiloti: GET /lms/lessons/[lesson_id]/
  static String lmsLessonDetail(String lessonId) => '/lms/lessons/$lessonId/';

  /// Uy vazifalari (Filtrlangan holda): GET /lms/homeworks/
  static const String lmsHomeworks = '/lms/homeworks/';

  /// Baholash portali qismi (Jurnal): GET /lms/grades/
  static const String lmsGrades = '/lms/grades/';

  /// Guruhning reyting (Leaderboard) jadvali: GET /lms/groups/[group_id]/leaderboard/
  static String lmsLeaderboard(String groupId) =>
      '/lms/groups/$groupId/leaderboard/';

  /// O'quv markazidagi ommaviy yangiliklar, Feed: GET /lms/announcements/
  static const String lmsAnnouncements = '/lms/announcements/';

  /// Testlar va imtihonlar ro'yxati: GET /lms/quizzes/
  static const String lmsQuizzes = '/lms/quizzes/';

  /// Muayyan testning savollari va variantlari: GET /lms/quizzes/[quiz_id]/
  static String lmsQuizDetail(String quizId) => '/lms/quizzes/$quizId/';

  // ─── 5. Notifications & Chat ─────────────────────────────────────────────
  static const String inAppNotifications = '/notifications/';
  static String groupChat(String groupId) => '/groups/$groupId/chat/';

  // ─── 6. Social & Feedback ────────────────────────────────────────────────
  static const String postReview = '/reviews/';
  static const String postComplaint = portalStudentComplaints;
  static const String studentComplaints = portalStudentComplaints;

  // ─── Aliases for Backward Compatibility ──────────────────────────────────
  static const String portalGroups = portalStudentGroups;
  static const String portalSchedule = portalStudentSchedule;
  static const String portalLessons = portalStudentLessons;
  static const String portalHomeworks = portalStudentHomeworks;
  static const String portalHomework = portalStudentHomeworks;
  static const String portalGrades = portalStudentGrades;
  static const String portalPayments = portalStudentPayments;
  static const String portalPaymentsHistory = portalStudentPayments;
  static const String portalAttendance = portalStudentAttendance;
  static const String portalAnnouncements = lmsAnnouncements;
  static const String announcements = lmsAnnouncements;
  static const String portalLeaderboard = '/lms/leaderboard/';
  static String groupLeaderboard(String groupId) => lmsLeaderboard(groupId);
  static const String portalNotifications = inAppNotifications;
  static const String portalQuiz = lmsQuizzes;
  static const String quizQuestions = lmsQuizzes;
  static const String studentSchedule = portalStudentSchedule;
  static const String studentLessons = portalStudentLessons;
  static const String studentHomework = portalStudentHomeworks;
  static const String studentPayments = portalStudentPayments;
  static const String dashboardStats = '/dashboard/stats/';
  static const String groups = '/groups/';
  static const String students = '/students/';
  static const String teachers = '/teachers/';
}

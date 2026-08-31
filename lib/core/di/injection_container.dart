import 'package:get_it/get_it.dart';
import 'package:m_it_student_platform/core/network/api_client.dart';

// Auth
import 'package:m_it_student_platform/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:m_it_student_platform/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:m_it_student_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:m_it_student_platform/features/auth/presentation/bloc/auth_bloc.dart';

// Home
import 'package:m_it_student_platform/features/home/data/datasources/home_remote_data_source.dart';
import 'package:m_it_student_platform/features/home/data/repositories/home_repository_impl.dart';
import 'package:m_it_student_platform/features/home/domain/repositories/home_repository.dart';

// Groups
import 'package:m_it_student_platform/features/groups/data/datasources/groups_remote_data_source.dart';
import 'package:m_it_student_platform/features/groups/data/repositories/groups_repository_impl.dart';
import 'package:m_it_student_platform/features/groups/domain/usecases/get_my_groups_usecase.dart';
import 'package:m_it_student_platform/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:m_it_student_platform/features/groups/presentation/bloc/groups_cubit.dart';

// Grades
import 'package:m_it_student_platform/features/grades/data/datasources/grades_remote_data_source.dart';
import 'package:m_it_student_platform/features/grades/data/repositories/grades_repository_impl.dart';
import 'package:m_it_student_platform/features/grades/domain/usecases/get_my_grades_usecase.dart';
import 'package:m_it_student_platform/features/grades/presentation/bloc/grades_bloc.dart';

// Attendance
import 'package:m_it_student_platform/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:m_it_student_platform/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:m_it_student_platform/features/attendance/domain/usecases/get_my_attendance_usecase.dart';
import 'package:m_it_student_platform/features/attendance/presentation/bloc/attendance_bloc.dart';

// Homework
import 'package:m_it_student_platform/features/homework/data/datasources/homework_remote_data_source.dart';
import 'package:m_it_student_platform/features/homework/data/repositories/homework_repository_impl.dart';
import 'package:m_it_student_platform/features/homework/domain/usecases/get_homework_usecase.dart';
import 'package:m_it_student_platform/features/homework/domain/usecases/submit_homework_usecase.dart';

// Chat
import 'package:m_it_student_platform/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:m_it_student_platform/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:m_it_student_platform/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:m_it_student_platform/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:m_it_student_platform/features/chat/presentation/bloc/chat_bloc.dart';

// Leaderboard
import 'package:m_it_student_platform/features/leaderboard/data/datasources/leaderboard_remote_data_source.dart';
import 'package:m_it_student_platform/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:m_it_student_platform/features/leaderboard/domain/usecases/get_leaderboard_usecase.dart';
import 'package:m_it_student_platform/features/leaderboard/presentation/bloc/leaderboard_bloc.dart';

// Notifications
import 'package:m_it_student_platform/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:m_it_student_platform/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:m_it_student_platform/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:m_it_student_platform/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:m_it_student_platform/features/notifications/presentation/bloc/notifications_bloc.dart';

// Announcements
import 'package:m_it_student_platform/features/announcements/data/datasources/announcements_remote_data_source.dart';
import 'package:m_it_student_platform/features/announcements/data/repositories/announcements_repository_impl.dart';
import 'package:m_it_student_platform/features/announcements/domain/usecases/get_announcements_usecase.dart';
import 'package:m_it_student_platform/features/announcements/presentation/bloc/announcements_bloc.dart';

// Payments
import 'package:m_it_student_platform/features/payments/data/datasources/payments_remote_data_source.dart';
import 'package:m_it_student_platform/features/payments/data/repositories/payments_repository_impl.dart';
import 'package:m_it_student_platform/features/payments/domain/usecases/get_payment_summary_usecase.dart';
import 'package:m_it_student_platform/features/payments/domain/usecases/get_transactions_usecase.dart';

// Quiz
import 'package:m_it_student_platform/features/quiz/data/datasources/quiz_remote_data_source.dart';
import 'package:m_it_student_platform/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:m_it_student_platform/features/quiz/domain/usecases/get_quiz_questions_usecase.dart';
// Complaints
import 'package:m_it_student_platform/features/complaints/data/datasources/complaints_remote_data_source.dart';
import 'package:m_it_student_platform/features/complaints/data/repositories/complaints_repository_impl.dart';

// Profile
import 'package:m_it_student_platform/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:m_it_student_platform/features/profile/domain/repositories/profile_repository.dart';

// Lessons
import 'package:m_it_student_platform/features/lessons/data/datasources/lessons_remote_data_source.dart';
import 'package:m_it_student_platform/features/lessons/data/repositories/lessons_repository_impl.dart';
import 'package:m_it_student_platform/features/lessons/domain/repositories/lessons_repository.dart';

// Reviews
import 'package:m_it_student_platform/features/reviews/data/datasources/reviews_remote_data_source.dart';
import 'package:m_it_student_platform/features/reviews/data/repositories/reviews_repository_impl.dart';

final sl = GetIt.instance;

/// Ilovadagi barcha Dependency Injection (DI) bog'liqliklarini sozlash
Future<void> initDependencies() async {
  // ── Core ─────────────────────────────────────────────────────────────────
  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(() => ApiClient());
  }

  // ── Auth Feature ─────────────────────────────────────────────────────────
  if (!sl.isRegistered<AuthRemoteDataSource>()) {
    sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()),
    );
  }
  if (!sl.isRegistered<AuthBloc>()) {
    sl.registerFactory<AuthBloc>(
      () => AuthBloc(authRepository: sl()),
    );
  }

  // ── Home Feature ─────────────────────────────────────────────────────────
  if (!sl.isRegistered<HomeRemoteDataSource>()) {
    sl.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<HomeRepository>()) {
    sl.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remoteDataSource: sl()),
    );
  }

  // ── Groups Feature ───────────────────────────────────────────────────────
  if (!sl.isRegistered<GroupsRemoteDataSource>()) {
    sl.registerLazySingleton<GroupsRemoteDataSource>(
      () => GroupsRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<GroupsRepository>()) {
    sl.registerLazySingleton<GroupsRepository>(
      () => GroupsRepositoryImpl(dataSource: sl()),
    );
  }
  if (!sl.isRegistered<GetMyGroupsUseCase>()) {
    sl.registerLazySingleton<GetMyGroupsUseCase>(
      () => GetMyGroupsUseCase(repository: sl()),
    );
  }
  if (!sl.isRegistered<GroupsBloc>()) {
    sl.registerFactory<GroupsBloc>(
      () => GroupsBloc(getMyGroupsUseCase: sl()),
    );
  }
  if (!sl.isRegistered<GroupsCubit>()) {
    sl.registerFactory<GroupsCubit>(
      () => GroupsCubit(getMyGroupsUseCase: sl()),
    );
  }

  // ── Grades Feature ───────────────────────────────────────────────────────
  if (!sl.isRegistered<GradesRemoteDataSource>()) {
    sl.registerLazySingleton<GradesRemoteDataSource>(
      () => GradesRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<GradesRepository>()) {
    sl.registerLazySingleton<GradesRepository>(
      () => GradesRepositoryImpl(dataSource: sl()),
    );
  }
  if (!sl.isRegistered<GetMyGradesUseCase>()) {
    sl.registerLazySingleton<GetMyGradesUseCase>(
      () => GetMyGradesUseCase(repository: sl()),
    );
  }
  if (!sl.isRegistered<GradesBloc>()) {
    sl.registerFactory<GradesBloc>(
      () => GradesBloc(getMyGradesUseCase: sl()),
    );
  }

  // ── Attendance Feature ───────────────────────────────────────────────────
  if (!sl.isRegistered<AttendanceRemoteDataSource>()) {
    sl.registerLazySingleton<AttendanceRemoteDataSource>(
      () => AttendanceRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<AttendanceRepository>()) {
    sl.registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(dataSource: sl()),
    );
  }
  if (!sl.isRegistered<GetMyAttendanceUseCase>()) {
    sl.registerLazySingleton<GetMyAttendanceUseCase>(
      () => GetMyAttendanceUseCase(repository: sl()),
    );
  }
  if (!sl.isRegistered<AttendanceBloc>()) {
    sl.registerFactory<AttendanceBloc>(
      () => AttendanceBloc(getMyAttendanceUseCase: sl()),
    );
  }

  // ── Homework Feature ─────────────────────────────────────────────────────
  if (!sl.isRegistered<HomeworkRemoteDataSource>()) {
    sl.registerLazySingleton<HomeworkRemoteDataSource>(
      () => HomeworkRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<HomeworkRepository>()) {
    sl.registerLazySingleton<HomeworkRepository>(
      () => HomeworkRepositoryImpl(dataSource: sl()),
    );
  }
  if (!sl.isRegistered<GetHomeworkUseCase>()) {
    sl.registerLazySingleton<GetHomeworkUseCase>(
      () => GetHomeworkUseCase(repository: sl()),
    );
  }
  if (!sl.isRegistered<SubmitHomeworkUseCase>()) {
    sl.registerLazySingleton<SubmitHomeworkUseCase>(
      () => SubmitHomeworkUseCase(repository: sl()),
    );
  }

  // ── Chat Feature ─────────────────────────────────────────────────────────
  if (!sl.isRegistered<ChatRemoteDataSource>()) {
    sl.registerLazySingleton<ChatRemoteDataSource>(
      () => ChatRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<ChatRepository>()) {
    sl.registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(dataSource: sl()),
    );
  }
  if (!sl.isRegistered<GetMessagesUseCase>()) {
    sl.registerLazySingleton<GetMessagesUseCase>(
      () => GetMessagesUseCase(repository: sl()),
    );
  }
  if (!sl.isRegistered<SendMessageUseCase>()) {
    sl.registerLazySingleton<SendMessageUseCase>(
      () => SendMessageUseCase(repository: sl()),
    );
  }
  if (!sl.isRegistered<ChatBloc>()) {
    sl.registerFactory<ChatBloc>(
      () => ChatBloc(
        getMessagesUseCase: sl(),
        sendMessageUseCase: sl(),
      ),
    );
  }

  // ── Leaderboard Feature ──────────────────────────────────────────────────
  if (!sl.isRegistered<LeaderboardRemoteDataSource>()) {
    sl.registerLazySingleton<LeaderboardRemoteDataSource>(
      () => LeaderboardRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<LeaderboardRepository>()) {
    sl.registerLazySingleton<LeaderboardRepository>(
      () => LeaderboardRepositoryImpl(dataSource: sl()),
    );
  }
  if (!sl.isRegistered<GetLeaderboardUseCase>()) {
    sl.registerLazySingleton<GetLeaderboardUseCase>(
      () => GetLeaderboardUseCase(repository: sl()),
    );
  }
  if (!sl.isRegistered<LeaderboardBloc>()) {
    sl.registerFactory<LeaderboardBloc>(
      () => LeaderboardBloc(getLeaderboardUseCase: sl()),
    );
  }

  // ── Notifications Feature ────────────────────────────────────────────────
  if (!sl.isRegistered<NotificationsRemoteDataSource>()) {
    sl.registerLazySingleton<NotificationsRemoteDataSource>(
      () => NotificationsRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<NotificationsRepository>()) {
    sl.registerLazySingleton<NotificationsRepository>(
      () => NotificationsRepositoryImpl(dataSource: sl()),
    );
  }
  if (!sl.isRegistered<GetNotificationsUseCase>()) {
    sl.registerLazySingleton<GetNotificationsUseCase>(
      () => GetNotificationsUseCase(repository: sl()),
    );
  }
  if (!sl.isRegistered<MarkNotificationReadUseCase>()) {
    sl.registerLazySingleton<MarkNotificationReadUseCase>(
      () => MarkNotificationReadUseCase(repository: sl()),
    );
  }
  if (!sl.isRegistered<NotificationsBloc>()) {
    sl.registerFactory<NotificationsBloc>(
      () => NotificationsBloc(
        getNotificationsUseCase: sl(),
        markNotificationReadUseCase: sl(),
      ),
    );
  }

  // ── Announcements Feature ────────────────────────────────────────────────
  if (!sl.isRegistered<AnnouncementsRemoteDataSource>()) {
    sl.registerLazySingleton<AnnouncementsRemoteDataSource>(
      () => AnnouncementsRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<AnnouncementsRepository>()) {
    sl.registerLazySingleton<AnnouncementsRepository>(
      () => AnnouncementsRepositoryImpl(dataSource: sl()),
    );
  }
  if (!sl.isRegistered<GetAnnouncementsUseCase>()) {
    sl.registerLazySingleton<GetAnnouncementsUseCase>(
      () => GetAnnouncementsUseCase(repository: sl()),
    );
  }
  if (!sl.isRegistered<AnnouncementsBloc>()) {
    sl.registerFactory<AnnouncementsBloc>(
      () => AnnouncementsBloc(getAnnouncementsUseCase: sl()),
    );
  }

  // ── Payments Feature ─────────────────────────────────────────────────────
  if (!sl.isRegistered<PaymentsRemoteDataSource>()) {
    sl.registerLazySingleton<PaymentsRemoteDataSource>(
      () => PaymentsRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<PaymentsRepository>()) {
    sl.registerLazySingleton<PaymentsRepository>(
      () => PaymentsRepositoryImpl(dataSource: sl()),
    );
  }
  if (!sl.isRegistered<GetPaymentSummaryUseCase>()) {
    sl.registerLazySingleton<GetPaymentSummaryUseCase>(
      () => GetPaymentSummaryUseCase(repository: sl()),
    );
  }
  if (!sl.isRegistered<GetTransactionsUseCase>()) {
    sl.registerLazySingleton<GetTransactionsUseCase>(
      () => GetTransactionsUseCase(repository: sl()),
    );
  }

  // ── Quiz Feature ─────────────────────────────────────────────────────────
  if (!sl.isRegistered<QuizRemoteDataSource>()) {
    sl.registerLazySingleton<QuizRemoteDataSource>(
      () => QuizRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<QuizRepository>()) {
    sl.registerLazySingleton<QuizRepository>(
      () => QuizRepositoryImpl(dataSource: sl()),
    );
  }
  if (!sl.isRegistered<GetQuizQuestionsUseCase>()) {
    sl.registerLazySingleton<GetQuizQuestionsUseCase>(
      () => GetQuizQuestionsUseCase(repository: sl()),
    );
  }

  // ── Complaints Feature ───────────────────────────────────────────────────
  if (!sl.isRegistered<ComplaintsRemoteDataSource>()) {
    sl.registerLazySingleton<ComplaintsRemoteDataSource>(
      () => ComplaintsRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<ComplaintsRepository>()) {
    sl.registerLazySingleton<ComplaintsRepository>(
      () => ComplaintsRepositoryImpl(dataSource: sl()),
    );
  }

  // ── Profile Feature ──────────────────────────────────────────────────────
  if (!sl.isRegistered<ProfileRemoteDataSource>()) {
    sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<ProfileRepository>()) {
    sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remoteDataSource: sl(), apiClient: sl()),
    );
  }

  // ── Lessons Feature ──────────────────────────────────────────────────────
  if (!sl.isRegistered<LessonsRemoteDataSource>()) {
    sl.registerLazySingleton<LessonsRemoteDataSource>(
      () => LessonsRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<LessonsRepository>()) {
    sl.registerLazySingleton<LessonsRepository>(
      () => LessonsRepositoryImpl(remoteDataSource: sl()),
    );
  }

  // ── Reviews Feature ──────────────────────────────────────────────────────
  if (!sl.isRegistered<ReviewsRemoteDataSource>()) {
    sl.registerLazySingleton<ReviewsRemoteDataSource>(
      () => ReviewsRemoteDataSourceImpl(apiClient: sl()),
    );
  }
  if (!sl.isRegistered<ReviewsRepository>()) {
    sl.registerLazySingleton<ReviewsRepository>(
      () => ReviewsRepositoryImpl(dataSource: sl()),
    );
  }
}

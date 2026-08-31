import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/features/homework/data/datasources/homework_remote_data_source.dart';
import 'package:m_it_student_platform/features/homework/domain/entities/homework.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';

export 'package:m_it_student_platform/features/homework/domain/entities/homework.dart';

class HomeworkRepository {
  HomeworkRepository._({HomeworkRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  static final HomeworkRepository instance = HomeworkRepository._();

  HomeworkRemoteDataSource? _remoteDataSource;

  HomeworkRemoteDataSource get _remoteSource {
    if (_remoteDataSource != null) return _remoteDataSource!;
    if (sl.isRegistered<HomeworkRemoteDataSource>()) {
      _remoteDataSource = sl<HomeworkRemoteDataSource>();
    } else {
      _remoteDataSource = HomeworkRemoteDataSourceImpl(
        apiClient: sl.isRegistered<ApiClient>() ? sl<ApiClient>() : ApiClient(),
      );
    }
    return _remoteDataSource!;
  }

  List<HomeworkItem> _homeworks = [];

  List<HomeworkItem> get homeworks => List.unmodifiable(_homeworks);

  Future<List<HomeworkItem>> getHomeworks({bool forceRefresh = false}) async {
    if (!AppConfig.useMockData) {
      try {
        final models = await _remoteSource.getHomeworkList();
        if (models.isNotEmpty) {
          _homeworks = models.map((m) => m.toEntity()).toList();
          return List.unmodifiable(_homeworks);
        }
      } catch (_) {
        // Fallback to local default list if offline or server is unreachable
      }
    }

    if (_homeworks.isNotEmpty && !forceRefresh) {
      return List.unmodifiable(_homeworks);
    }

    final student = MockProfileRepository.currentStudent;
    final currentGroupName = student.group.isNotEmpty
        ? student.group
        : (student.courseName.isNotEmpty ? student.courseName : 'Guruh');

    _homeworks = [
      HomeworkItem(
        id: 'hw-01',
        title: 'REST API va BLoC Pattern vazifasi',
        course: currentGroupName,
        deadline: 'Bugun, 23:59',
        description:
            '$currentGroupName guruhi uchun REST API orqali ma\'lumotlarni olib keluvchi va BLoC state management yordamida ishlovchi mobil ilova yaratish.',
        status: HomeworkStatus.pending,
      ),
      HomeworkItem(
        id: 'hw-02',
        title: 'Custom UI va Interaktiv Animatsiyalar',
        course: currentGroupName,
        deadline: 'Ertaga, 20:00',
        description:
            '$currentGroupName guruhi uchun maxsus dizayn komponentlari va animatsiyalar yaratish.',
        status: HomeworkStatus.pending,
      ),
    ];

    return List.unmodifiable(_homeworks);
  }

  Future<void> submitHomework(
    String id,
    String githubUrl, {
    String? comment,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    // 1. Live API submit
    if (!AppConfig.useMockData) {
      try {
        await _remoteSource.submitHomework(
          homeworkId: id,
          githubUrl: githubUrl.startsWith('http') ? githubUrl : null,
          text: comment ?? githubUrl,
          comment: comment,
          filePath: filePath,
          fileBytes: fileBytes,
          fileName: fileName,
        );
      } catch (_) {}
    }

    // 2. Optimistic local update
    final index = _homeworks.indexWhere((h) => h.id == id);
    if (index != -1) {
      _homeworks[index] = _homeworks[index].copyWith(
        status: HomeworkStatus.submitted,
        githubRepoUrl: githubUrl,
      );
    }
  }
}

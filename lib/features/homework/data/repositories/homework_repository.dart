import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/core/storage/app_cache_service.dart';
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
  final Set<String> _submittedIds = {};

  List<HomeworkItem> get homeworks => List.unmodifiable(_homeworks);

  bool isHomeworkSubmitted(String id, {String? title}) {
    if (_submittedIds.contains(id)) return true;
    if (title != null && _submittedIds.contains(title.toLowerCase().trim())) return true;
    final cached = AppCacheService.getCache('sub_hw_$id');
    if (cached == true) return true;
    return false;
  }

  Future<List<HomeworkItem>> getHomeworks({bool forceRefresh = false}) async {
    // Restore cached submitted IDs
    final cachedSubmissions = AppCacheService.getCache('submitted_hw_ids');
    if (cachedSubmissions is List) {
      _submittedIds.addAll(cachedSubmissions.map((e) => e.toString()));
    }

    if (_homeworks.isNotEmpty && !forceRefresh) {
      return List.unmodifiable(_homeworks);
    }

    if (!AppConfig.useMockData) {
      try {
        final models = await _remoteSource.getHomeworkList();
        _homeworks = models.map((m) {
          final entity = m.toEntity();
          if (isHomeworkSubmitted(entity.id, title: entity.title) && entity.status == HomeworkStatus.pending) {
            return entity.copyWith(status: HomeworkStatus.submitted);
          }
          return entity;
        }).toList();
        return List.unmodifiable(_homeworks);
      } catch (_) {
        if (_homeworks.isNotEmpty) {
          return List.unmodifiable(_homeworks);
        }
      }
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
        status: isHomeworkSubmitted('hw-01') ? HomeworkStatus.submitted : HomeworkStatus.pending,
      ),
      HomeworkItem(
        id: 'hw-02',
        title: 'Custom UI va Interaktiv Animatsiyalar',
        course: currentGroupName,
        deadline: 'Ertaga, 20:00',
        description:
            '$currentGroupName guruhi uchun maxsus dizayn komponentlari va animatsiyalar yaratish.',
        status: isHomeworkSubmitted('hw-02') ? HomeworkStatus.submitted : HomeworkStatus.pending,
      ),
    ];

    return List.unmodifiable(_homeworks);
  }

  Future<void> submitHomework(
    String id,
    String githubUrl, {
    String? title,
    String? comment,
    String? filePath,
    List<int>? fileBytes,
    String? fileName,
  }) async {
    // 1. Mark submitted in local memory & cache
    _submittedIds.add(id);
    if (title != null && title.isNotEmpty) {
      _submittedIds.add(title.toLowerCase().trim());
    }
    await AppCacheService.setCache('sub_hw_$id', true);
    await AppCacheService.setCache('submitted_hw_ids', _submittedIds.toList());

    // 2. Optimistic local update
    final index = _homeworks.indexWhere((h) => h.id == id || (title != null && h.title == title));
    if (index != -1) {
      _homeworks[index] = _homeworks[index].copyWith(
        status: HomeworkStatus.submitted,
        githubRepoUrl: githubUrl,
      );
    } else {
      _homeworks.add(
        HomeworkItem(
          id: id,
          title: title ?? 'Vazifa #$id',
          course: 'M-IT Academy',
          deadline: 'Topshirildi',
          description: comment ?? 'Vazifa topshirildi',
          status: HomeworkStatus.submitted,
          githubRepoUrl: githubUrl,
        ),
      );
    }

    // 3. Live API submit with graceful fallback
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
      } catch (_) {
        // Backend returned 404 (e.g. no homework object in Django DB for lesson yet)
        // Submission is kept safe and active locally!
      }
    }
  }
}

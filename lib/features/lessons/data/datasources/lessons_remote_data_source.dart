import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';

abstract class LessonsRemoteDataSource {
  Future<dynamic> fetchStudentGroups();
  Future<dynamic> fetchTodayLessons();
  Future<dynamic> fetchAllLessons();
  Future<dynamic> fetchLessonDetails(String lessonId);
}

class LessonsRemoteDataSourceImpl implements LessonsRemoteDataSource {
  LessonsRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<dynamic> fetchStudentGroups() async {
    try {
      return await _apiClient.get(AppConfig.portalStudentGroups);
    } catch (_) {
      return await _apiClient.get(AppConfig.portalStudentSchedule);
    }
  }

  @override
  Future<dynamic> fetchTodayLessons() async {
    try {
      final res = await _apiClient.get(AppConfig.portalStudentSchedule);
      if (res != null) return res;
    } catch (_) {}
    try {
      final res = await _apiClient.get(AppConfig.portalStudentLessons);
      if (res != null) return res;
    } catch (_) {}
    return await _apiClient.get(AppConfig.portalStudentGroups);
  }

  @override
  Future<dynamic> fetchAllLessons() async {
    try {
      final res = await _apiClient.get(AppConfig.portalStudentLessons);
      if (res != null) return res;
    } catch (_) {}
    try {
      final res = await _apiClient.get(AppConfig.lmsLessons);
      if (res != null) return res;
    } catch (_) {}
    try {
      final res = await _apiClient.get(AppConfig.portalStudentSchedule);
      if (res != null) return res;
    } catch (_) {}
    return await _apiClient.get(AppConfig.portalStudentGroups);
  }

  @override
  Future<dynamic> fetchLessonDetails(String lessonId) async {
    try {
      return await _apiClient.get(AppConfig.lmsLessonDetail(lessonId));
    } catch (_) {
      return await _apiClient.get('${AppConfig.groups}$lessonId/');
    }
  }
}

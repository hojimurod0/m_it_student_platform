import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> fetchProfile();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body);
  Future<dynamic> fetchAttendance();
  Future<dynamic> fetchGrades();
  Future<dynamic> fetchGroups();
  Future<Map<String, dynamic>> fetchProgress();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final res = await _apiClient.get(AppConfig.portalStudentProfile);
      if (res is Map<String, dynamic>) {
        return Map<String, dynamic>.from(res);
      }
    } catch (_) {
      // Fallback to /auth/me/ if portal profile endpoint is not available
    }

    final res = await _apiClient.get(AppConfig.authMe);
    if (res is Map<String, dynamic>) {
      return Map<String, dynamic>.from(res);
    }
    throw const ApiException('Profil ma\'lumotlarini yuklab bo\'lmadi');
  }

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    try {
      final res = await _apiClient.patch(AppConfig.portalStudentProfile, body: body);
      if (res is Map<String, dynamic>) {
        return Map<String, dynamic>.from(res);
      }
    } catch (_) {
      // Fallback if patch is not supported by legacy backend
    }
    return body;
  }

  @override
  Future<dynamic> fetchAttendance() async {
    return await _apiClient.get(AppConfig.portalStudentAttendance);
  }

  @override
  Future<dynamic> fetchGrades() async {
    try {
      return await _apiClient.get(AppConfig.portalStudentGrades);
    } catch (_) {
      return await _apiClient.get(AppConfig.dashboardStats);
    }
  }

  @override
  Future<dynamic> fetchGroups() async {
    return await _apiClient.get(AppConfig.portalStudentGroups);
  }

  @override
  Future<Map<String, dynamic>> fetchProgress() async {
    try {
      final res = await _apiClient.get(AppConfig.portalStudentProgress);
      if (res is Map<String, dynamic>) {
        return Map<String, dynamic>.from(res);
      }
      // Agar serverdan boshqa format kelsa — bo'sh map qaytaramiz
      return {};
    } catch (_) {
      return {};
    }
  }
}

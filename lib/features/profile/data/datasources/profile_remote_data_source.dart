import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> fetchProfile();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body);
  Future<dynamic> fetchAttendance();
  Future<dynamic> fetchGrades();
  Future<dynamic> fetchHomeworks();
  Future<dynamic> fetchGroups();
  Future<Map<String, dynamic>> fetchProgress();
  Future<void> deleteProfile({String password = '', String? reason});
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
      try {
        return await _apiClient.get(AppConfig.portalStudentProgress);
      } catch (_) {
        return [];
      }
    }
  }

  @override
  Future<dynamic> fetchHomeworks() async {
    try {
      return await _apiClient.get(AppConfig.portalStudentHomeworks);
    } catch (_) {
      return [];
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
      return {};
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> deleteProfile({String password = '', String? reason}) async {
    // 1. Attempt standard DELETE /portal/student/profile/
    try {
      await _apiClient.delete(
        AppConfig.portalStudentProfile,
      );
      return;
    } catch (_) {}

    // 2. Attempt POST /portal/student/profile/delete/
    try {
      await _apiClient.post(
        '${AppConfig.portalStudentProfile}delete/',
        body: {
          'password': password,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      return;
    } catch (_) {}

    // 3. Fallback: Submit official account deletion request via CRM ticket/complaint
    final safeReason = (reason != null && reason.trim().isNotEmpty)
        ? reason.trim()
        : 'Sabab ko\'rsatilmadi';
    final requestContent =
        'Talaba ilova orqali hisobini butunlay o\'chirishni so\'radi. Sabab: $safeReason.';
    try {
      await _apiClient.post(
        AppConfig.portalStudentComplaints,
        body: {
          'subject': 'Hisobni o\'chirish talabi',
          'content': requestContent,
          'body': requestContent,
          'text': requestContent,
          'message': requestContent,
          'topic': 'Hisobni o\'chirish talabi',
          'description': requestContent,
          'comment': safeReason,
        },
      );
    } catch (_) {}

    // 4. Invalidate server auth token
    try {
      await _apiClient.post(AppConfig.authLogout);
    } catch (_) {}
  }
}

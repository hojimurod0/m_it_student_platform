import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({required String phone, required String password});
  Future<void> logout();
  Future<Map<String, dynamic>> getMe();
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<void> sendFcmToken(String fcmToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final cleanLogin = phone.trim();
    final response = await _apiClient.post(
      AppConfig.authLogin,
      body: {
        'username': cleanLogin,
        'phone': cleanLogin,
        'password': password,
      },
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw const ApiException('Serverdan kutilmagan javob qaytdi');
  }

  @override
  Future<void> logout() async {
    await _apiClient.post(AppConfig.authLogout);
  }

  @override
  Future<Map<String, dynamic>> getMe() async {
    final response = await _apiClient.get(AppConfig.authMe);
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw const ApiException('Foydalanuvchi ma\'lumotlarini yuklab bo\'lmadi');
  }

  @override
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final candidateEndpoints = [
      AppConfig.authChangePassword,
      '/portal/student/change-password/',
      '/auth/password/change/',
      '/auth/users/set_password/',
    ];

    dynamic lastError;

    for (final endpoint in candidateEndpoints) {
      try {
        final response = await _apiClient.post(
          endpoint,
          body: {
            'old_password': oldPassword,
            'current_password': oldPassword,
            'new_password': newPassword,
            'new_password1': newPassword,
            'new_password_confirm': newPassword,
            'password': newPassword,
          },
        );
        if (response is Map<String, dynamic>) {
          return response;
        }
        return {'status': 'success'};
      } on ApiException catch (e) {
        lastError = e;
        if (e.statusCode == 404) {
          continue;
        }
        rethrow;
      } catch (e) {
        lastError = e;
      }
    }

    if (lastError is AppException) {
      throw lastError;
    }
    throw ApiException(lastError?.toString() ?? 'Parolni o\'zgartirib bo\'lmadi');
  }

  @override
  Future<void> sendFcmToken(String fcmToken) async {
    await _apiClient.post(
      AppConfig.authFcmToken,
      body: {
        'token': fcmToken,
        'fcm_token': fcmToken,
        'registration_id': fcmToken,
      },
    );
  }
}

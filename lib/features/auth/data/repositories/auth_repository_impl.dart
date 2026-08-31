import 'dart:async';
import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/core/utils/app_logger.dart';
import 'package:m_it_student_platform/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:m_it_student_platform/features/auth/domain/models/user_model.dart';
import 'package:m_it_student_platform/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    ApiClient? apiClient,
  })  : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSourceImpl(apiClient: apiClient),
        _apiClient = apiClient ?? ApiClient();

  final AuthRemoteDataSource _remoteDataSource;
  final ApiClient _apiClient;
  UserModel? _currentUser;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null || LocalStorageService.isLoggedIn();

  @override
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {

    // 2. Real Backend (JarvisX API) Login
    try {
      final data = await _remoteDataSource.login(phone: phone, password: password);
      
      // Extract Token
      final token = data['token'] ?? data['key'] ?? data['access'] ?? data['auth_token'] ?? data['access_token'];
      if (token != null && token.toString().isNotEmpty) {
        final tokenStr = token.toString();
        _apiClient.setAuthToken(tokenStr);
        await LocalStorageService.saveAuthToken(tokenStr);
      }

      // Extract User Profile
      UserModel user;
      if (data['user'] is Map<String, dynamic>) {
        user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      } else if (data['data'] is Map<String, dynamic>) {
        user = UserModel.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        // Fetch full profile from /auth/me/
        try {
          final meData = await _remoteDataSource.getMe();
          AppLogger.info('👤 User Profile (/auth/me/): $meData', tag: 'AUTH_ME');
          user = UserModel.fromJson(meData);
        } catch (_) {
          user = UserModel.fromJson(data);
        }
      }

      AppLogger.info('👤 Logged-in Role: ${user.role.name}, User ID: ${user.userId}', tag: 'AUTH');
      _currentUser = user;
      await LocalStorageService.saveUserData(user.toJson());
      await LocalStorageService.setLoggedIn(true);

      return user;
    } on UnauthorizedException catch (e) {
      throw AuthException(e.message);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } on NetworkException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      final msg = e.toString();
      if (msg.contains('<') || msg.contains('500') || msg.contains('Server Error')) {
        throw const AuthException('Serverda vaqtinchalik texnik xatolik (500). Iltimos, birozdan so\'ng qayta urinib ko\'ring.');
      }
      throw AuthException(msg.replaceAll('Exception:', '').trim());
    }
  }

  @override
  Future<void> logout() async {
    final token = _apiClient.currentToken ?? LocalStorageService.getAuthToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _remoteDataSource.logout();
      } catch (e) {
        AppLogger.info('Server logout notice: $e', tag: 'AUTH');
      }
    }
    _currentUser = null;
    _apiClient.setAuthToken(null);
    await LocalStorageService.clearAuth();
  }

  @override
  Future<UserModel?> restoreSession() async {
    final token = LocalStorageService.getAuthToken();
    final cachedUserJson = LocalStorageService.getUserData();

    if (token != null && token.isNotEmpty) {
      _apiClient.setAuthToken(token);

      // 1. Try restoring from cache first
      if (cachedUserJson != null) {
        try {
          _currentUser = UserModel.fromJson(cachedUserJson);
        } catch (_) {}
      }

      // 2. Fetch fresh user data from server in background if real backend
      if (!AppConfig.useMockData) {
        try {
          final freshData = await _remoteDataSource.getMe();
          AppLogger.info('👤 Restored Profile (/auth/me/): $freshData', tag: 'AUTH_ME');
          _currentUser = UserModel.fromJson(freshData);
          AppLogger.info('👤 Restored Role: ${_currentUser!.role.name}, User ID: ${_currentUser!.userId}', tag: 'AUTH');
          await LocalStorageService.saveUserData(_currentUser!.toJson());
        } catch (e) {
          if (e is UnauthorizedException) {
            await logout();
            return null;
          }
          // If network error, continue with cached user
        }
      }

      return _currentUser;
    }
    return null;
  }

  @override
  Future<void> sendFcmToken(String fcmToken) async {
    try {
      await _remoteDataSource.sendFcmToken(fcmToken);
      AppLogger.success('📲 FCM Token serverga muvaffaqiyatli yuborildi', tag: 'AUTH_FCM');
    } catch (e) {
      AppLogger.warning('FCM token yuborishda xatolik: $e', tag: 'AUTH_FCM');
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      AppLogger.success('🔐 Parol muvaffaqiyatli o\'zgartirildi', tag: 'AUTH_PASSWORD');
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString().replaceAll('Exception:', '').trim());
    }
  }
}

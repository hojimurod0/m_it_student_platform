import 'package:m_it_student_platform/features/auth/domain/models/user_model.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

abstract class AuthRepository {
  UserModel? get currentUser;
  bool get isAuthenticated;
  Future<UserModel> login({required String phone, required String password});
  Future<void> logout();
  Future<UserModel?> restoreSession();
  Future<void> sendFcmToken(String fcmToken);
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

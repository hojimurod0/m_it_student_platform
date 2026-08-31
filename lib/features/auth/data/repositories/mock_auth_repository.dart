import 'dart:async';
import 'package:m_it_student_platform/features/auth/domain/models/user_model.dart';
import 'package:m_it_student_platform/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository._();

  static final MockAuthRepository instance = MockAuthRepository._();

  // Default development Student credentials (ONLY for local mock testing)
  static const String devPhone = '+998901234567';
  static const String devPassword = '123456';

  static const UserModel defaultDevStudent = UserModel(
    userId: 'DEV-STUDENT-001',
    name: 'Test Student',
    phone: devPhone,
    role: UserRole.student,
    email: 'student@m-it.uz',
    groupName: 'Flutter-2026-F1',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
  );

  UserModel? _currentUser;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  /// Helper to normalize phone numbers (e.g. "+998 90 123 45 67" -> "+998901234567")
  static String normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 9) {
      return '+998$digits';
    } else if (digits.length == 12 && digits.startsWith('998')) {
      return '+$digits';
    }
    return raw.trim().replaceAll(' ', '');
  }

  @override
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    // Simulate brief network latency for realistic UX
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final normalizedInput = normalizePhone(phone);
    final normalizedDev = normalizePhone(devPhone);

    if (normalizedInput == normalizedDev && password.trim() == devPassword) {
      _currentUser = defaultDevStudent;
      return _currentUser!;
    }

    throw const AuthException('Telefon raqami yoki parol noto\'g\'ri');
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    _currentUser = null;
  }

  @override
  Future<UserModel?> restoreSession() async {
    return _currentUser;
  }

  @override
  Future<void> sendFcmToken(String fcmToken) async {
    // Mock repository: no-op for offline dev mode
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}

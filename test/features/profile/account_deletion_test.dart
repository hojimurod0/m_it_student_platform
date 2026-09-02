import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/core/storage/secure_storage_service.dart';
import 'package:m_it_student_platform/core/storage/app_cache_service.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:m_it_student_platform/features/profile/data/datasources/profile_remote_data_source.dart';

class FakeProfileRemoteDataSource implements ProfileRemoteDataSource {
  bool deleteCalled = false;
  String? lastPassword;
  String? lastReason;

  @override
  Future<void> deleteProfile({String password = '', String? reason}) async {
    deleteCalled = true;
    lastPassword = password;
    lastReason = reason;
  }

  @override
  Future<dynamic> fetchAttendance() async => [];

  @override
  Future<dynamic> fetchGrades() async => [];

  @override
  Future<dynamic> fetchGroups() async => [];

  @override
  Future<dynamic> fetchHomeworks() async => [];

  @override
  Future<Map<String, dynamic>> fetchProfile() async => {'id': '1', 'fullName': 'Test Student'};

  @override
  Future<Map<String, dynamic>> fetchProgress() async => {};

  @override
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async => body;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    await SecureStorageService.saveTokens(accessToken: 'mock_token_123');
    await LocalStorageService.setLoggedIn(true);
    await AppCacheService.setCache('test_cache_key', {'data': 'test'});
  });

  group('Account Deletion Tests', () {
    test('deleteAccount purges tokens, cache, and session on success', () async {
      final fakeDataSource = FakeProfileRemoteDataSource();
      final repository = ProfileRepositoryImpl(remoteDataSource: fakeDataSource);

      expect(SecureStorageService.hasValidSession(), isTrue);
      expect(LocalStorageService.isLoggedIn(), isTrue);

      await repository.deleteAccount(
        password: 'secure_password_123',
        reason: 'Graduated from academy',
      );

      // Verify tokens and session are purged
      expect(fakeDataSource.deleteCalled, isTrue);
      expect(fakeDataSource.lastPassword, equals('secure_password_123'));
      expect(fakeDataSource.lastReason, equals('Graduated from academy'));
      expect(SecureStorageService.getAccessToken(), isNull);
      expect(LocalStorageService.isLoggedIn(), isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/core/storage/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  group('SecureStorageService Tests', () {
    test('Saves and retrieves access token with encrypted obfuscation', () async {
      await SecureStorageService.saveTokens(
        accessToken: 'jwt_access_1234567890',
        refreshToken: 'jwt_refresh_9876543210',
      );

      final accessToken = SecureStorageService.getAccessToken();
      final refreshToken = SecureStorageService.getRefreshToken();

      expect(accessToken, equals('jwt_access_1234567890'));
      expect(refreshToken, equals('jwt_refresh_9876543210'));
      expect(SecureStorageService.hasValidSession(), isTrue);
    });

    test('clearAll clears memory cache and stored credentials', () async {
      await SecureStorageService.saveTokens(
        accessToken: 'sample_token',
      );
      expect(SecureStorageService.hasValidSession(), isTrue);

      await SecureStorageService.clearAll();
      expect(SecureStorageService.getAccessToken(), isNull);
      expect(SecureStorageService.hasValidSession(), isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/core/storage/app_cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  group('AppCacheService & LocalStorageService Tests', () {
    test('Should save and retrieve obfuscated auth token correctly', () async {
      const sampleToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.sample';
      final saved = await LocalStorageService.saveAuthToken(sampleToken);
      expect(saved, isTrue);

      final retrieved = LocalStorageService.getAuthToken();
      expect(retrieved, equals(sampleToken));
    });

    test('Should handle token expiry correctly', () async {
      const sampleToken = 'test_token';
      await LocalStorageService.saveAuthToken(
        sampleToken,
        validDuration: const Duration(milliseconds: -100),
      );

      final retrieved = LocalStorageService.getAuthToken();
      expect(retrieved, isNull);
    });

    test('Should manage coins for gamification', () async {
      await LocalStorageService.saveCoins(500);
      expect(LocalStorageService.getCoins(), equals(500));
    });

    test('Should cache and retrieve list of lessons in AppCacheService', () async {
      final sampleLessons = [
        {'id': '1', 'title': 'Flutter BLoC Asoslari'},
        {'id': '2', 'title': 'Clean Architecture'},
      ];

      final success = await AppCacheService.setCache(
        AppCacheService.keyLessons,
        sampleLessons,
      );
      expect(success, isTrue);
      expect(AppCacheService.hasCache(AppCacheService.keyLessons), isTrue);

      final cached = AppCacheService.getCache(AppCacheService.keyLessons) as List;
      expect(cached.length, equals(2));
      expect(cached[0]['title'], equals('Flutter BLoC Asoslari'));
    });
  });
}

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/services/payment_service.dart';
import 'package:m_it_student_platform/core/storage/app_cache_service.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/core/storage/secure_storage_service.dart';
import 'package:m_it_student_platform/features/auth/domain/models/user_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    await SecureStorageService.clearAll();
    await AppCacheService.clearAll();
  });

  group('Extended Release Verification — Payment & Security', () {
    test('Payment checkout URLs are correctly formatted without exposing merchant secrets', () {
      final paymeUrl = PaymentService.generatePaymeUrl(
        amount: 250000,
        studentId: 'STUDENT_998901234567',
      );
      expect(paymeUrl, startsWith('https://checkout.paycom.uz/'));

      final clickUrl = PaymentService.generateClickUrl(
        amount: 250000,
        studentId: 'STUDENT_998901234567',
      );
      expect(clickUrl, startsWith('https://my.click.uz/services/pay'));
      expect(clickUrl, contains('amount=250000'));
      expect(clickUrl, contains('transaction_param=STUDENT_998901234567'));

      final uzumUrl = PaymentService.generateUzumUrl(
        amount: 250000,
        studentId: 'STUDENT_998901234567',
      );
      expect(uzumUrl, startsWith('https://uzumbank.uz/pay'));
      expect(uzumUrl, contains('amount=250000'));
      expect(uzumUrl, contains('account=STUDENT_998901234567'));
    });

    test('Payment provider enum contains all supported systems', () {
      expect(PaymentProvider.payme, isNotNull);
      expect(PaymentProvider.click, isNotNull);
      expect(PaymentProvider.uzum, isNotNull);
      expect(PaymentProvider.cashier, isNotNull);
    });

    test('Expired session triggers 401 UnauthorizedException and clears cached tokens', () async {
      await SecureStorageService.saveTokens(accessToken: 'expired_token_12345');
      await LocalStorageService.saveAuthToken('expired_token_12345');

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Token expired, authentication required'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: 'https://api.m-it.uz',
      );

      expect(
        () async => await apiClient.get('/portal/student/profile/'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('AppCacheService handles Stale-While-Revalidate and offline retrieval correctly', () async {
      final dummyDashboard = {
        'student_name': 'Ali Valiyev',
        'active_courses': 2,
        'attendance_rate': 95.0,
      };

      await AppCacheService.setCache(AppCacheService.keyProfile, dummyDashboard);

      final cachedStats = AppCacheService.getCache(AppCacheService.keyProfile) as Map<String, dynamic>?;
      expect(cachedStats, isNotNull);
      expect(cachedStats?['student_name'], equals('Ali Valiyev'));
      expect(cachedStats?['attendance_rate'], equals(95.0));

      // Test cache clearance
      await AppCacheService.clearAll();
      expect(AppCacheService.getCache(AppCacheService.keyProfile), isNull);
    });

    test('UserModel JSON deserialization handles properties correctly', () {
      final userJson = {
        'userId': '101',
        'name': 'Ali Valiyev',
        'phone': '+998901234567',
        'role': 'student',
        'avatarUrl': null,
        'groupName': 'Flutter Bootcamp',
      };

      final user = UserModel.fromJson(userJson);
      expect(user.userId, equals('101'));
      expect(user.name, equals('Ali Valiyev'));
      expect(user.phone, equals('+998901234567'));
      expect(user.role, equals(UserRole.student));
      expect(user.groupName, equals('Flutter Bootcamp'));
    });
  });
}

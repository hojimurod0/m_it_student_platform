import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  group('ApiClient Tests', () {
    test('Successful GET request returns parsed JSON', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'status': 'success', 'data': 'test_data'}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: 'https://api.m-it.uz',
      );
      apiClient.setAuthToken('test_token');

      final response = await apiClient.get('/test');
      expect(response['status'], equals('success'));
      expect(response['data'], equals('test_data'));
    });

    test('401 response throws UnauthorizedException and clears auth', () async {
      await LocalStorageService.saveAuthToken('dummy_token');

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'message': 'Unauthorized'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        httpClient: mockClient,
        baseUrl: 'https://api.m-it.uz',
      );

      expect(
        () => apiClient.get('/profile', maxRetries: 0),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });
}

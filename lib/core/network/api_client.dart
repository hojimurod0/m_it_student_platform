import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/core/utils/app_logger.dart';

import 'package:m_it_student_platform/core/error/exceptions.dart';
export 'package:m_it_student_platform/core/error/exceptions.dart';

/// Base custom API exception with HTTP response details
class ApiException extends AppException {
  const ApiException(String message, {this.statusCode, this.data, dynamic cause})
      : super(message, cause);
  final int? statusCode;
  final dynamic data;

  @override
  String toString() => '$message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class TimeoutExceptionCustom extends AppException {
  const TimeoutExceptionCustom([super.message = 'Server javob berish vaqti tugadi', super.cause]);
}

/// Robust ApiClient with token mutex, race-condition protection, and idempotent retry
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.baseUrl;

  final http.Client _httpClient;
  final String _baseUrl;
  String? _authToken;

  /// Global callback invoked when 401 Unauthorized occurs and refresh fails
  static void Function()? onUnauthorized;

  // Mutex for handling concurrent 401s without multiple refresh loops
  static Completer<bool>? _refreshCompleter;

  void setAuthToken(String? token) {
    _authToken = token;
    if (token != null && token.isNotEmpty) {
      LocalStorageService.saveAuthToken(token);
    } else {
      LocalStorageService.clearAuth();
    }
  }

  String? get currentToken => _authToken ?? LocalStorageService.getAuthToken();

  Map<String, String> _buildHeaders([Map<String, String>? extra]) {
    final lang = LocalStorageService.getLanguage().name;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Language': lang,
      'X-App-Platform': 'm-it-student-flutter',
    };

    final effectiveToken = currentToken;
    if (effectiveToken != null && effectiveToken.isNotEmpty) {
      if (effectiveToken.startsWith('Bearer ')) {
        headers['Authorization'] = effectiveToken;
      } else {
        // JarvisX & DRF standard Bearer Token auth
        headers['Authorization'] = 'Bearer $effectiveToken';
      }
    }

    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    var cleanPath = path.startsWith('/') ? path : '/$path';
    
    // Ensure Django REST Framework trailing slash if not present
    if (cleanPath.contains('?')) {
      final parts = cleanPath.split('?');
      final basePath = parts[0].endsWith('/') ? parts[0] : '${parts[0]}/';
      cleanPath = '$basePath?${parts.sublist(1).join('?')}';
    } else if (!cleanPath.endsWith('/')) {
      cleanPath = '$cleanPath/';
    }

    final fullUrl = '$_baseUrl$cleanPath';
    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParams.map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
    }
    return uri;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    int maxRetries = 1,
  }) async {
    final uri = _buildUri(path, queryParams);
    return _sendRequestWithRetry(
      () => _httpClient.get(uri, headers: _buildHeaders(headers)).timeout(AppConfig.requestTimeout),
      method: 'GET',
      url: uri.toString(),
      path: path,
      maxRetries: maxRetries,
    );
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    int maxRetries = 0,
  }) async {
    final uri = _buildUri(path);
    return _sendRequestWithRetry(
      () => _httpClient
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.requestTimeout),
      method: 'POST',
      url: uri.toString(),
      body: body,
      path: path,
      maxRetries: maxRetries,
    );
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    return _sendRequestWithRetry(
      () => _httpClient
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.requestTimeout),
      method: 'PUT',
      url: uri.toString(),
      body: body,
      path: path,
    );
  }

  Future<dynamic> patch(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    return _sendRequestWithRetry(
      () => _httpClient
          .patch(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.requestTimeout),
      method: 'PATCH',
      url: uri.toString(),
      body: body,
      path: path,
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    return _sendRequestWithRetry(
      () => _httpClient.delete(uri, headers: _buildHeaders(headers)).timeout(AppConfig.requestTimeout),
      method: 'DELETE',
      url: uri.toString(),
      path: path,
    );
  }

  Future<dynamic> postMultipart(
    String path, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path);
    final stopwatch = Stopwatch()..start();
    try {
      final request = http.MultipartRequest('POST', uri);
      final defaultHeaders = _buildHeaders(headers);
      defaultHeaders.remove('Content-Type'); // Boundary is set automatically
      request.headers.addAll(defaultHeaders);

      if (fields != null) {
        request.fields.addAll(fields);
      }
      if (files != null) {
        request.files.addAll(files);
      }

      final streamedResponse = await request.send().timeout(AppConfig.requestTimeout * 2);
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();

      return _handleResponse(
        response,
        method: 'POST (Multipart)',
        url: uri.toString(),
        duration: stopwatch.elapsed,
        requestBody: fields,
      );
    } on SocketException catch (e) {
      stopwatch.stop();
      AppLogger.network(
        method: 'POST (Multipart)',
        url: uri.toString(),
        error: 'Tarmoq xatosi: $e',
        duration: stopwatch.elapsed,
      );
      throw NetworkException('Internetga ulanish mavjud emas', e);
    } catch (e) {
      stopwatch.stop();
      if (e is AppException) rethrow;
      throw ApiException('Fayl yuklashda xatolik yuz berdi: $e');
    }
  }

  Future<dynamic> _sendRequestWithRetry(
    Future<http.Response> Function() requestFn, {
    required String method,
    required String url,
    dynamic body,
    String? path,
    int maxRetries = 0,
  }) async {
    // If another request is currently refreshing the token, wait for it
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      await _refreshCompleter!.future;
    }



    int attempts = 0;
    while (true) {
      attempts++;
      final stopwatch = Stopwatch()..start();
      try {
        final response = await requestFn();
        stopwatch.stop();

        if (response.statusCode == 401 && path != null && !path.contains(AppConfig.authLogin)) {
          final refreshed = await _tryRefreshToken();
          if (refreshed && attempts <= 1) {
            continue; // Retry with new token
          }
        }

        return _handleResponse(response, method: method, url: url, duration: stopwatch.elapsed, requestBody: body);
      } on SocketException catch (e) {
        stopwatch.stop();
        if (attempts <= maxRetries && method == 'GET') {
          await Future<void>.delayed(Duration(milliseconds: 300 * attempts));
          continue;
        }
        AppLogger.network(method: method, url: url, error: e, duration: stopwatch.elapsed, requestBody: body);
        throw const NetworkException('Internet aloqasini tekshiring');
      } on TimeoutException catch (e) {
        stopwatch.stop();
        if (attempts <= maxRetries && method == 'GET') {
          await Future<void>.delayed(Duration(milliseconds: 300 * attempts));
          continue;
        }
        AppLogger.network(method: method, url: url, error: e, duration: stopwatch.elapsed, requestBody: body);
        throw const TimeoutExceptionCustom('Server javob berish vaqti tugadi');
      } catch (e) {
        stopwatch.stop();
        AppLogger.network(method: method, url: url, error: e, duration: stopwatch.elapsed, requestBody: body);
        if (e is UnauthorizedException) {
          await LocalStorageService.clearAuth();
          rethrow;
        }
        if (e is ApiException || e is NetworkException || e is TimeoutExceptionCustom) {
          rethrow;
        }
        throw ApiException(e.toString());
      }
    }
  }

  /// Mutex-locked automated token refresh to prevent concurrent race conditions
  Future<bool> _tryRefreshToken() async {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      return _refreshCompleter!.future;
    }

    final refreshToken = LocalStorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    _refreshCompleter = Completer<bool>();
    AppLogger.info('🔄 Token muddati o\'tgan. Refresh Token orqali yangilanmoqda...', tag: 'AUTH_REFRESH');

    try {
      final refreshUri = _buildUri('/auth/token/refresh/');
      final response = await _httpClient.post(
        refreshUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'] ?? data['token'] ?? data['access_token'];
        if (newAccess != null) {
          setAuthToken(newAccess.toString());
          AppLogger.success('✅ Access Token muvaffaqiyatli yangilandi', tag: 'AUTH_REFRESH');
          _refreshCompleter!.complete(true);
          return true;
        }
      }
      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      AppLogger.warning('Refresh token muvaffaqiyatsiz bo\'ldi: $e', tag: 'AUTH_REFRESH');
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  dynamic _handleResponse(
    http.Response response, {
    required String method,
    required String url,
    required Duration duration,
    dynamic requestBody,
  }) {
    final statusCode = response.statusCode;
    dynamic decodedBody;

    if (response.body.isNotEmpty) {
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        decodedBody = response.body;
      }
    }

    AppLogger.network(
      method: method,
      url: url,
      statusCode: statusCode,
      duration: duration,
      requestBody: requestBody,
      responseBody: decodedBody,
    );

    if (statusCode >= 200 && statusCode < 300) {
      return decodedBody;
    }

    if (statusCode == 401) {
      _authToken = null;
      LocalStorageService.clearAuth();
      onUnauthorized?.call();
      final errorMsg = _extractErrorMessage(decodedBody, defaultMsg: 'Sessiya muddati tugagan. Qaytadan kiring');
      throw UnauthorizedException(errorMsg);
    }

    if (statusCode == 403) {
      final errorMsg = _extractErrorMessage(decodedBody, defaultMsg: 'Ushbu amalni bajarish uchun ruxsat mavjud emas');
      throw ApiException(errorMsg, statusCode: 403, data: decodedBody);
    }

    if (statusCode >= 500) {
      throw const ApiException('Serverda vaqtinchalik texnik xatolik (500). Iltimos, birozdan so\'ng qayta urinib ko\'ring.');
    }

    final message = _extractErrorMessage(decodedBody, defaultMsg: 'Server xatosi: $statusCode');
    throw ApiException(message, statusCode: statusCode, data: decodedBody);
  }

  String _extractErrorMessage(dynamic body, {required String defaultMsg}) {
    if (body == null) return defaultMsg;
    if (body is String) {
      final text = body.trim();
      if (text.startsWith('<') || text.contains('<!doctype') || text.contains('<html') || text.contains('Server Error')) {
        return 'Serverda vaqtinchalik texnik xatolik (500). Iltimos, birozdan so\'ng qayta urinib ko\'ring.';
      }
      return text.isNotEmpty ? text : defaultMsg;
    }
    if (body is Map) {
      if (body.containsKey('detail') && body['detail'] != null) {
        return body['detail'].toString();
      }
      if (body.containsKey('message') && body['message'] != null) {
        return body['message'].toString();
      }
      if (body.containsKey('error') && body['error'] != null) {
        return body['error'].toString();
      }
      if (body.containsKey('non_field_errors') && body['non_field_errors'] is List) {
        return (body['non_field_errors'] as List).join(', ');
      }
      final fieldErrors = <String>[];
      body.forEach((key, value) {
        if (value is List) {
          fieldErrors.add('$key: ${value.join(", ")}');
        } else if (value is String) {
          fieldErrors.add('$key: $value');
        }
      });
      if (fieldErrors.isNotEmpty) {
        return fieldErrors.join('; ');
      }
    }
    return defaultMsg;
  }
}

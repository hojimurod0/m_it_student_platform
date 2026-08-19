import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:m_it_student_platform/core/network/app_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.data});
  final String message;
  final int? statusCode;
  final dynamic data;

  @override
  String toString() => 'ApiException ($statusCode): $message';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'Internet aloqasi mavjud emas']);
  final String message;

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Sessiya muddati tugagan']);
  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.baseUrl;

  final http.Client _httpClient;
  final String _baseUrl;
  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _buildHeaders([Map<String, String>? extra]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Platform': 'm-it-student-flutter',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (extra != null) {
      headers.addAll(extra);
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
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
  }) async {
    return _sendRequest(() {
      final uri = _buildUri(path, queryParams);
      return _httpClient
          .get(uri, headers: _buildHeaders(headers))
          .timeout(AppConfig.requestTimeout);
    });
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return _sendRequest(() {
      final uri = _buildUri(path);
      return _httpClient
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.requestTimeout);
    });
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    return _sendRequest(() {
      final uri = _buildUri(path);
      return _httpClient
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConfig.requestTimeout);
    });
  }

  Future<dynamic> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    return _sendRequest(() {
      final uri = _buildUri(path);
      return _httpClient
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(AppConfig.requestTimeout);
    });
  }

  Future<dynamic> _sendRequest(Future<http.Response> Function() requestFn) async {
    try {
      final response = await requestFn();
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('Internet aloqasini tekshiring');
    } on TimeoutException {
      throw const NetworkException('Server javob berish vaqti tugadi');
    } catch (e) {
      if (e is ApiException || e is UnauthorizedException || e is NetworkException) {
        rethrow;
      }
      throw ApiException(e.toString());
    }
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic decodedBody;

    if (response.body.isNotEmpty) {
      try {
        decodedBody = jsonDecode(response.body);
      } catch (_) {
        decodedBody = response.body;
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decodedBody;
    }

    if (statusCode == 401 || statusCode == 403) {
      throw UnauthorizedException(
        decodedBody is Map ? (decodedBody['message'] ?? 'Ruxsat berilmadi') : 'Ruxsat berilmadi',
      );
    }

    final message = decodedBody is Map
        ? (decodedBody['message'] ?? decodedBody['error'] ?? 'Xatolik yuz berdi')
        : 'Server xatosi: $statusCode';

    throw ApiException(message.toString(), statusCode: statusCode, data: decodedBody);
  }
}

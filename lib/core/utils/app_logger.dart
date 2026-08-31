import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, success, warning, error, network }

class AppLogger {
  AppLogger._();

  // ANSI color escape codes for terminal formatting
  static const String _reset = '\x1B[0m';
  static const String _cyan = '\x1B[36m';
  static const String _blue = '\x1B[34m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _red = '\x1B[31m';
  static const String _magenta = '\x1B[35m';

  static void debug(String message, {String tag = 'DEBUG'}) {
    if (!kDebugMode) return;
    _log('🔍 [$tag] $message', color: _cyan, name: tag);
  }

  static void info(String message, {String tag = 'INFO'}) {
    if (!kDebugMode) return;
    _log('ℹ️ [$tag] $message', color: _blue, name: tag);
  }

  static void success(String message, {String tag = 'SUCCESS'}) {
    if (!kDebugMode) return;
    _log('✅ [$tag] $message', color: _green, name: tag);
  }

  static void warning(String message, {String tag = 'WARN'}) {
    if (!kDebugMode) return;
    _log('⚠️ [$tag] $message', color: _yellow, name: tag);
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String tag = 'ERROR',
  }) {
    final buffer = StringBuffer('❌ [$tag] $message');
    if (error != null) buffer.write('\nError: $error');
    if (stackTrace != null) buffer.write('\nStackTrace: $stackTrace');

    if (kDebugMode) {
      _log(buffer.toString(), color: _red, name: tag, error: error, stackTrace: stackTrace);
    }
  }

  static void network({
    required String method,
    required String url,
    int? statusCode,
    dynamic requestBody,
    dynamic responseBody,
    Duration? duration,
    Object? error,
  }) {
    if (!kDebugMode) return;

    final isSuccess = statusCode != null && statusCode >= 200 && statusCode < 300;
    final color = error != null || (statusCode != null && statusCode >= 400)
        ? _red
        : (isSuccess ? _green : _magenta);

    final icon = isSuccess ? '🌐 [API SUCCESS]' : '📡 [API ${error != null ? "ERROR" : "REQUEST"}]';
    final durationStr = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    final statusStr = statusCode != null ? ' [$statusCode]' : '';

    final logMsg = StringBuffer('$icon $method $url$statusStr$durationStr');
    if (requestBody != null) {
      logMsg.write('\n  ↳ Body: ${_sanitize(requestBody)}');
    }
    if (responseBody != null) {
      if (isSuccess) {
        logMsg.write('\n  ↳ Response Data: ${_sanitize(responseBody)}');
      } else {
        logMsg.write('\n  ↳ Error Response: ${_sanitize(responseBody)}');
      }
    }
    if (error != null) {
      logMsg.write('\n  ↳ Exception: $error');
    }

    _log(logMsg.toString(), color: color, name: 'HTTP');
  }

  /// Sanitizes sensitive fields from logs (Passwords, tokens, credentials, card info)
  static dynamic _sanitize(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      final sanitized = Map<String, dynamic>.from(data);
      const sensitiveKeys = {
        'password',
        'old_password',
        'new_password',
        'token',
        'access',
        'refresh',
        'access_token',
        'refresh_token',
        'authorization',
        'otp',
        'secret',
        'card_number',
        'cvv',
      };

      for (final key in sanitized.keys.toList()) {
        final keyLower = key.toString().toLowerCase();
        if (sensitiveKeys.contains(keyLower) ||
            keyLower.contains('password') ||
            keyLower.contains('token')) {
          sanitized[key] = '***[PROTECTED]***';
        } else if (sanitized[key] is Map || sanitized[key] is List) {
          sanitized[key] = _sanitize(sanitized[key]);
        }
      }
      return sanitized;
    } else if (data is List) {
      return data.map((item) => _sanitize(item)).toList();
    } else if (data is String) {
      final trimmed = data.trim();
      if (trimmed.startsWith('<!doctype') || trimmed.startsWith('<!DOCTYPE') || trimmed.startsWith('<html') || trimmed.contains('<body')) {
        return '[HTML Webpage / Server Response (${trimmed.length} chars)]';
      }
      if (data.contains('password') || data.contains('token')) {
        return '***[PROTECTED_CONTENT]***';
      }
    }
    return data;
  }

  static void _log(
    String message, {
    required String color,
    required String name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    final formatted = '$color[$time] $message$_reset';
    
    // Use dart:developer log for IDE logging console
    dev.log(
      formatted,
      name: name,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

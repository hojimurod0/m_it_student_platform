import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';

/// Service for securely managing authentication credentials, JWT access & refresh tokens.
class SecureStorageService {
  SecureStorageService._();

  static const String _keyAccessToken = 'secure_jwt_access_token';
  static const String _keyRefreshToken = 'secure_jwt_refresh_token';
  static const String _keyTokenExpiry = 'secure_jwt_token_expiry';

  // In-memory cache for fast, zero-delay synchronous access
  static String? _cachedAccessToken;
  static String? _cachedRefreshToken;
  static int? _cachedExpiry;

  /// Initialize and load credentials into memory cache
  static Future<void> init() async {
    try {
      final rawAccess = LocalStorageService.getString(_keyAccessToken);
      if (rawAccess != null && rawAccess.isNotEmpty) {
        _cachedAccessToken = _decrypt(rawAccess);
      }

      final rawRefresh = LocalStorageService.getString(_keyRefreshToken);
      if (rawRefresh != null && rawRefresh.isNotEmpty) {
        _cachedRefreshToken = _decrypt(rawRefresh);
      }

      _cachedExpiry = int.tryParse(LocalStorageService.getString(_keyTokenExpiry) ?? '');
    } catch (e) {
      debugPrint('SecureStorageService initialization warning: $e');
    }
  }

  /// Save access and optional refresh tokens securely
  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    Duration? validDuration,
  }) async {
    _cachedAccessToken = accessToken;
    await LocalStorageService.setString(_keyAccessToken, _encrypt(accessToken));

    if (refreshToken != null && refreshToken.isNotEmpty) {
      _cachedRefreshToken = refreshToken;
      await LocalStorageService.setString(_keyRefreshToken, _encrypt(refreshToken));
    }

    if (validDuration != null) {
      final expiryTime = DateTime.now().add(validDuration).millisecondsSinceEpoch;
      _cachedExpiry = expiryTime;
      await LocalStorageService.setString(_keyTokenExpiry, expiryTime.toString());
    }
  }

  /// Get current valid access token
  static String? getAccessToken() {
    if (_cachedAccessToken == null || _cachedAccessToken!.isEmpty) {
      final raw = LocalStorageService.getString(_keyAccessToken);
      if (raw != null && raw.isNotEmpty) {
        _cachedAccessToken = _decrypt(raw);
      }
    }

    // Check expiry
    if (_cachedExpiry != null && DateTime.now().millisecondsSinceEpoch > _cachedExpiry!) {
      // Access token expired, still keep refresh token
      return null;
    }

    return _cachedAccessToken;
  }

  /// Get current refresh token
  static String? getRefreshToken() {
    if (_cachedRefreshToken == null || _cachedRefreshToken!.isEmpty) {
      final raw = LocalStorageService.getString(_keyRefreshToken);
      if (raw != null && raw.isNotEmpty) {
        _cachedRefreshToken = _decrypt(raw);
      }
    }
    return _cachedRefreshToken;
  }

  /// Check if user has active session
  static bool hasValidSession() {
    final token = getAccessToken();
    final refresh = getRefreshToken();
    return (token != null && token.isNotEmpty) || (refresh != null && refresh.isNotEmpty);
  }

  /// Clear all secured tokens upon logout
  static Future<void> clearAll() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedExpiry = null;
    await LocalStorageService.remove(_keyAccessToken);
    await LocalStorageService.remove(_keyRefreshToken);
    await LocalStorageService.remove(_keyTokenExpiry);
  }

  // Obfuscation / Encryption layer
  static String _encrypt(String value) {
    final bytes = utf8.encode(value);
    return base64Encode(bytes.reversed.toList());
  }

  static String? _decrypt(String value) {
    try {
      final bytes = base64Decode(value);
      return utf8.decode(bytes.reversed.toList());
    } catch (_) {
      return value;
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';

/// AppCacheService manages local JSON caching for offline-first capabilities.
class AppCacheService {
  AppCacheService._();

  static const String _prefix = 'cache_';
  static const String _ttlPrefix = 'cache_ttl_';
  static const String keyLessons = '${_prefix}lessons';
  static const String keyAnnouncements = '${_prefix}announcements';
  static const String keyFeaturedClass = '${_prefix}featured_class';
  static const String keyPayments = '${_prefix}payments';
  static const String keyPaymentSummary = '${_prefix}payment_summary';
  static const String keyHomeworks = '${_prefix}homeworks';
  static const String keyGroups = '${_prefix}groups';
  static const String keyProfile = '${_prefix}student_profile';
  static const String keyGrades = '${_prefix}student_grades';
  static const String keyAttendance = '${_prefix}student_attendance';
  static const String keyLastSync = '${_prefix}last_sync_timestamp';

  /// Save raw JSON list or map into local cache with optional TTL
  static Future<bool> setCache(
    String key,
    dynamic data, {
    Duration? ttl,
  }) async {
    try {
      final jsonString = jsonEncode(data);
      final success = await LocalStorageService.setString(key, jsonString);
      if (success) {
        await LocalStorageService.setString(
          keyLastSync,
          DateTime.now().toIso8601String(),
        );

        if (ttl != null) {
          final expiry = DateTime.now().add(ttl).millisecondsSinceEpoch;
          await LocalStorageService.setString(
            '$_ttlPrefix$key',
            expiry.toString(),
          );
        } else {
          await LocalStorageService.remove('$_ttlPrefix$key');
        }
      }
      return success;
    } catch (e) {
      debugPrint('AppCacheService setCache error for key "$key": $e');
      return false;
    }
  }

  /// Retrieve cached JSON data (returns null if expired or missing)
  static dynamic getCache(String key) {
    try {
      final ttlRaw = LocalStorageService.getString('$_ttlPrefix$key');
      if (ttlRaw != null) {
        final expiry = int.tryParse(ttlRaw);
        if (expiry != null && DateTime.now().millisecondsSinceEpoch > expiry) {
          // Expired -> clean up
          clearKey(key);
          return null;
        }
      }

      final raw = LocalStorageService.getString(key);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw);
    } catch (e) {
      debugPrint('AppCacheService getCache error for key "$key": $e');
      return null;
    }
  }

  /// Check if a valid, non-expired cache key exists
  static bool hasCache(String key) {
    return getCache(key) != null;
  }

  /// Clear specific cache key and its TTL
  static Future<bool> clearKey(String key) async {
    await LocalStorageService.remove('$_ttlPrefix$key');
    return LocalStorageService.remove(key);
  }

  /// Clear all cached data
  static Future<void> clearAllCache() async {
    final keys = [
      keyLessons,
      keyAnnouncements,
      keyFeaturedClass,
      keyPayments,
      keyPaymentSummary,
      keyHomeworks,
      keyProfile,
      keyLastSync,
    ];
    for (final k in keys) {
      await clearKey(k);
    }
  }

  /// Get last sync date time
  static DateTime? getLastSyncTime() {
    final raw = LocalStorageService.getString(keyLastSync);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}

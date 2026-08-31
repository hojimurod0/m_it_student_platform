import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:m_it_student_platform/core/state/app_settings.dart';
import 'package:m_it_student_platform/core/storage/secure_storage_service.dart';

/// Local storage service for handling preferences, cached data, and auth session.
class LocalStorageService {
  LocalStorageService._();
  static SharedPreferences? _prefs;

  // Keys
  static const String _keyUser = 'auth_user_data';
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyLanguage = 'app_language';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyCoins = 'student_mit_coins';
  static const String _keyHasCompletedOnboarding = 'has_completed_onboarding';
  static const String _keyHasSelectedLanguage = 'has_selected_language';

  /// Initialize SharedPreferences and SecureStorage instances
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await SecureStorageService.init();
    } catch (e) {
      debugPrint('LocalStorageService init error: $e');
    }
  }

  // ── 1. Auth & Secured Token ──
  static Future<bool> saveAuthToken(String token, {String? refreshToken, Duration? validDuration}) async {
    await SecureStorageService.saveTokens(
      accessToken: token,
      refreshToken: refreshToken,
      validDuration: validDuration,
    );
    await setLoggedIn(true);
    return true;
  }

  static String? getAuthToken() {
    return SecureStorageService.getAccessToken();
  }

  static String? getRefreshToken() {
    return SecureStorageService.getRefreshToken();
  }

  static Future<bool> setLoggedIn(bool value) async {
    return _prefs?.setBool(_keyIsLoggedIn, value) ?? Future.value(false);
  }

  static bool isLoggedIn() {
    final hasToken = SecureStorageService.hasValidSession();
    final loggedInFlag = _prefs?.getBool(_keyIsLoggedIn) ?? false;
    return hasToken && loggedInFlag;
  }

  static Future<bool> saveUserData(Map<String, dynamic> userJson) async {
    return _prefs?.setString(_keyUser, jsonEncode(userJson)) ?? Future.value(false);
  }

  static Map<String, dynamic>? getUserData() {
    final raw = _prefs?.getString(_keyUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearAuth() async {
    await SecureStorageService.clearAll();
    await _prefs?.remove(_keyUser);
    await _prefs?.setBool(_keyIsLoggedIn, false);
  }

  // ── 2. Theme Preferences ──
  static Future<bool> saveThemeMode(ThemeMode mode) async {
    return _prefs?.setString(_keyThemeMode, mode.name) ?? Future.value(false);
  }

  static ThemeMode getThemeMode() {
    final name = _prefs?.getString(_keyThemeMode);
    if (name == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => ThemeMode.system,
    );
  }

  // ── 3. Language Preferences ──
  static Future<bool> saveLanguage(AppLanguage language) async {
    return _prefs?.setString(_keyLanguage, language.name) ?? Future.value(false);
  }

  static AppLanguage getLanguage() {
    final name = _prefs?.getString(_keyLanguage);
    if (name == null) return AppLanguage.uz;
    return AppLanguage.values.firstWhere(
      (l) => l.name == name,
      orElse: () => AppLanguage.uz,
    );
  }

  // ── 4. Gamification (Coins) ──
  static int getCoins() {
    return _prefs?.getInt(_keyCoins) ?? 350;
  }

  static Future<bool> saveCoins(int coins) async {
    return _prefs?.setInt(_keyCoins, coins) ?? Future.value(false);
  }

  // ── 5. Onboarding & First-Run Flow ──
  static bool hasCompletedOnboarding() {
    return _prefs?.getBool(_keyHasCompletedOnboarding) ?? false;
  }

  static Future<bool> setCompletedOnboarding(bool value) async {
    return _prefs?.setBool(_keyHasCompletedOnboarding, value) ?? Future.value(false);
  }

  static bool hasSelectedLanguage() {
    return _prefs?.getBool(_keyHasSelectedLanguage) ?? false;
  }

  static Future<bool> setSelectedLanguage(bool value) async {
    return _prefs?.setBool(_keyHasSelectedLanguage, value) ?? Future.value(false);
  }

  // ── 5. Raw Cache Access for AppCacheService ──
  static Future<bool> setString(String key, String value) async {
    return _prefs?.setString(key, value) ?? Future.value(false);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    return _prefs?.setBool(key, value) ?? Future.value(false);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<bool> remove(String key) async {
    return _prefs?.remove(key) ?? Future.value(false);
  }

  // ── 6. Clear Everything ──
  static Future<bool> clearAll() async {
    return _prefs?.clear() ?? Future.value(false);
  }
}


import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';

enum AppLanguage {
  uz('O\'zbek tili', '🇺🇿', Locale('uz')),
  en('English', '🇺🇸', Locale('en')),
  ru('Русский язык', '🇷🇺', Locale('ru'));

  const AppLanguage(this.label, this.flag, this.locale);

  final String label;
  final String flag;
  final Locale locale;
}

class AppSettings extends ChangeNotifier {
  AppSettings({
    ThemeMode? initialThemeMode,
    AppLanguage? initialLanguage,
  })  : _themeMode = initialThemeMode ?? LocalStorageService.getThemeMode(),
        _language = initialLanguage ?? LocalStorageService.getLanguage();

  ThemeMode _themeMode;
  AppLanguage _language;

  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  Locale get locale => _language.locale;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      LocalStorageService.saveThemeMode(mode);
      notifyListeners();
    }
  }

  void setLanguage(AppLanguage lang) {
    if (_language != lang) {
      _language = lang;
      LocalStorageService.saveLanguage(lang);
      notifyListeners();
    }
  }
}

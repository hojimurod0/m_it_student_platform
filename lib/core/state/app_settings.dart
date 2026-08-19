import 'package:flutter/material.dart';

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
    ThemeMode initialThemeMode = ThemeMode.system,
    AppLanguage initialLanguage = AppLanguage.uz,
  })  : _themeMode = initialThemeMode,
        _language = initialLanguage;

  ThemeMode _themeMode;
  AppLanguage _language;

  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  Locale get locale => _language.locale;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void setLanguage(AppLanguage lang) {
    if (_language != lang) {
      _language = lang;
      notifyListeners();
    }
  }
}

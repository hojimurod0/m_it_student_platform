import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/localization/app_translations.dart';
import 'package:m_it_student_platform/core/state/app_scope.dart';
import 'package:m_it_student_platform/core/state/app_settings.dart';

import 'package:m_it_student_platform/core/utils/day_formatter.dart';

extension AppStringsExtension on BuildContext {
  AppSettings get settings => AppScope.of(this);
  AppLanguage get language => AppScope.of(this).language;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  String tr(String key) {
    return AppTranslations.get(language, key);
  }

  String formatScheduleDays(String? rawDays, {bool full = false}) {
    return DayFormatter.format(rawDays, language, full: full);
  }
}

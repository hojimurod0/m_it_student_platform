import 'package:m_it_student_platform/core/state/app_settings.dart';

/// Dars kunlarini (masalan: "Du - Chor - Juma", "dush pay juma", "Se - Pay - Shan")
/// tanlangan tilga (O'zbek, Rus, Ingliz) to'g'ri o'girib beruvchi universal yordamchi.
class DayFormatter {
  DayFormatter._();

  static const Map<String, int> _dayMap = {
    // 1: Dushanba / Monday / Понедельник
    'du': 1,
    'dush': 1,
    'dushanba': 1,
    'mon': 1,
    'monday': 1,
    'пн': 1,
    'пон': 1,
    'понедельник': 1,

    // 2: Seshanba / Tuesday / Вторник
    'se': 2,
    'sesh': 2,
    'seshanba': 2,
    'tue': 2,
    'tuesday': 2,
    'вт': 2,
    'вторник': 2,

    // 3: Chorshanba / Wednesday / Среда
    'chor': 3,
    'chorsh': 3,
    'chorshanba': 3,
    'wed': 3,
    'wednesday': 3,
    'ср': 3,
    'среда': 3,

    // 4: Payshanba / Thursday / Четверг
    'pay': 4,
    'paysh': 4,
    'payshanba': 4,
    'thu': 4,
    'thursday': 4,
    'чт': 4,
    'четверг': 4,

    // 5: Juma / Friday / Пятница
    'jum': 5,
    'juma': 5,
    'fri': 5,
    'friday': 5,
    'пт': 5,
    'пятница': 5,

    // 6: Shanba / Saturday / Суббота
    'sha': 6,
    'shan': 6,
    'shanba': 6,
    'sat': 6,
    'saturday': 6,
    'сб': 6,
    'суббота': 6,

    // 7: Yakshanba / Sunday / Воскресенье
    'yak': 7,
    'yaksh': 7,
    'yakshanba': 7,
    'sun': 7,
    'sunday': 7,
    'вс': 7,
    'воскресенье': 7,
  };

  static const Map<AppLanguage, Map<int, String>> _shortDayNames = {
    AppLanguage.uz: {
      1: 'Du',
      2: 'Se',
      3: 'Chor',
      4: 'Pay',
      5: 'Juma',
      6: 'Shan',
      7: 'Yak',
    },
    AppLanguage.en: {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun',
    },
    AppLanguage.ru: {
      1: 'Пн',
      2: 'Вт',
      3: 'Ср',
      4: 'Чт',
      5: 'Пт',
      6: 'Сб',
      7: 'Вс',
    },
  };

  static const Map<AppLanguage, Map<int, String>> _fullDayNames = {
    AppLanguage.uz: {
      1: 'Dushanba',
      2: 'Seshanba',
      3: 'Chorshanba',
      4: 'Payshanba',
      5: 'Juma',
      6: 'Shanba',
      7: 'Yakshanba',
    },
    AppLanguage.en: {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    },
    AppLanguage.ru: {
      1: 'Понедельник',
      2: 'Вторник',
      3: 'Среда',
      4: 'Четверг',
      5: 'Пятница',
      6: 'Суббота',
      7: 'Воскресенье',
    },
  };

  /// Dars kunlari qatorini joriy tilga moslab formatlaydi
  static String format(String? raw, AppLanguage lang, {bool full = false}) {
    if (raw == null || raw.trim().isEmpty) return '';
    final trimmed = raw.trim();

    // Maxsus iboralar tekshiruvi
    final lower = trimmed.toLowerCase();
    if (lower.contains('juft') ||
        lower.contains('even') ||
        lower.contains('четн')) {
      switch (lang) {
        case AppLanguage.en:
          return 'Even days (Tue-Thu-Sat)';
        case AppLanguage.ru:
          return 'Четные дни (Вт-Чт-Сб)';
        case AppLanguage.uz:
          return 'Juft kunlar (Se-Pay-Shan)';
      }
    }
    if (lower.contains('toq') ||
        lower.contains('odd') ||
        lower.contains('нечет')) {
      switch (lang) {
        case AppLanguage.en:
          return 'Odd days (Mon-Wed-Fri)';
        case AppLanguage.ru:
          return 'Нечетные дни (Пн-Ср-Пт)';
        case AppLanguage.uz:
          return 'Toq kunlar (Du-Chor-Juma)';
      }
    }
    if (lower.contains('har kun') ||
        lower.contains('every day') ||
        lower.contains('каждый день')) {
      switch (lang) {
        case AppLanguage.en:
          return 'Every day';
        case AppLanguage.ru:
          return 'Каждый день';
        case AppLanguage.uz:
          return 'Har kuni';
      }
    }

    // Ajratuvchini aniqlash
    String separator = ' - ';
    if (trimmed.contains(' - ')) {
      separator = ' - ';
    } else if (trimmed.contains(', ')) {
      separator = ', ';
    } else if (trimmed.contains(',')) {
      separator = ', ';
    } else if (trimmed.contains('-')) {
      separator = ' - ';
    } else if (trimmed.contains(' / ')) {
      separator = ' / ';
    } else if (trimmed.contains('/')) {
      separator = ' / ';
    }

    final parts = trimmed
        .split(RegExp(r'[\s,\-/•]+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return trimmed;

    final translatedParts = <String>[];
    bool anyMatched = false;

    for (final part in parts) {
      final key = part.toLowerCase().replaceAll(RegExp(r'[^a-zа-яё]'), '');
      final dayIndex = _dayMap[key];
      if (dayIndex != null) {
        anyMatched = true;
        final names = full ? _fullDayNames[lang] : _shortDayNames[lang];
        translatedParts.add(names?[dayIndex] ?? part);
      } else {
        translatedParts.add(part);
      }
    }

    if (!anyMatched) return trimmed;
    return translatedParts.join(separator);
  }
}

import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/lessons/domain/models/lesson_model.dart';

class ReminderService {
  ReminderService._();

  static const String _lessonReminderPrefix = 'lesson_reminder_';
  static const String _paymentReminderKey = 'payment_reminder_enabled';

  /// Check if reminder is enabled for a specific lesson
  static bool isLessonReminderEnabled(String lessonId) {
    return LocalStorageService.getBool('$_lessonReminderPrefix$lessonId') ?? false;
  }

  /// Toggle reminder for a specific lesson
  static Future<bool> toggleLessonReminder(
    BuildContext context,
    Lesson lesson,
  ) async {
    AppHaptics.selection();
    final key = '$_lessonReminderPrefix${lesson.id}';
    final current = LocalStorageService.getBool(key) ?? false;
    final newState = !current;

    await LocalStorageService.setBool(key, newState);

    if (context.mounted) {
      if (newState) {
        AppHaptics.success();
        MitToast.success(
          context,
          '🔔 "${lesson.subject}" darsi uchun eslatma yoqildi (${lesson.startTime} dan 30 daqiqa oldin xabar beriladi)',
        );
      } else {
        AppHaptics.light();
        MitToast.info(
          context,
          '🔕 Dars eslatmasi o\'chirildi',
        );
      }
    }
    return newState;
  }

  /// Check if payment reminder is enabled
  static bool isPaymentReminderEnabled() {
    return LocalStorageService.getBool(_paymentReminderKey) ?? true;
  }

  /// Toggle payment reminder
  static Future<bool> togglePaymentReminder(BuildContext context) async {
    AppHaptics.selection();
    final current = isPaymentReminderEnabled();
    final newState = !current;
    await LocalStorageService.setBool(_paymentReminderKey, newState);

    if (context.mounted) {
      if (newState) {
        AppHaptics.success();
        MitToast.success(
          context,
          '🔔 Oylik to\'lov muddati eslatmasi yoqildi',
        );
      } else {
        AppHaptics.light();
        MitToast.info(
          context,
          '🔕 To\'lov eslatmasi o\'chirildi',
        );
      }
    }
    return newState;
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/services/notification_service.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/core/utils/app_bloc_observer.dart';
import 'package:m_it_student_platform/core/utils/app_logger.dart';

/// Ilova ishga tushishidan oldin barcha global initsializatsiyani bajaradi.
abstract final class AppBootstrap {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initDependencies();
    Bloc.observer = AppBlocObserver();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      AppLogger.error(
        'Flutter framework xatosi: ${details.exceptionAsString()}',
        error: details.exception,
        stackTrace: details.stack,
        tag: 'FLUTTER_ERROR',
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error(
        'Asinxron kutilmagan xatolik: $error',
        error: error,
        stackTrace: stack,
        tag: 'UNCAUGHT_ASYNC',
      );
      return true;
    };

    AppLogger.info('🚀 Ilova ishga tushmoqda...', tag: 'APP_START');

    await LocalStorageService.init();
    AppLogger.success('Mahalliy xotira ishga tushdi', tag: 'STORAGE');

    // NotificationService ni fon rejimida ishga tushirish (UI threadni qotirmaslik uchun)
    NotificationService.instance.initialize().then((_) {
      AppLogger.success('Push Bildirishnomalar xizmati ishga tushdi', tag: 'NOTIFICATION');
    }).catchError((dynamic e) {
      AppLogger.error('NotificationService xatosi: $e', tag: 'NOTIFICATION');
    });

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}

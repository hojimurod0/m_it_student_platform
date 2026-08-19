import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_it_student_platform/core/state/app_scope.dart';
import 'package:m_it_student_platform/core/state/app_settings.dart';
import 'package:m_it_student_platform/core/theme/app_theme.dart';
import 'package:m_it_student_platform/features/splash/presentation/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MitStudentApp(settings: AppSettings()));
}

class MitStudentApp extends StatelessWidget {
  const MitStudentApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      notifier: settings,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, child) {
          return MaterialApp(
            title: 'M-IT Academy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

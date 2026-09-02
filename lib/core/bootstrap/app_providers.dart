import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/routes/app_router.dart';
import 'package:m_it_student_platform/core/state/app_scope.dart';
import 'package:m_it_student_platform/core/state/app_settings.dart';
import 'package:m_it_student_platform/core/theme/app_theme.dart';
import 'package:m_it_student_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:m_it_student_platform/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:m_it_student_platform/features/splash/presentation/splash_screen.dart';

/// Ilova uchun barcha provider va widget daraxtini birlashtiradi.
class MitStudentApp extends StatefulWidget {
  const MitStudentApp({super.key});

  @override
  State<MitStudentApp> createState() => _MitStudentAppState();
}

class _MitStudentAppState extends State<MitStudentApp> {
  final AppSettings _settings = AppSettings();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>.value(
      value: sl<AuthRepository>(),
      child: BlocProvider<AuthBloc>(
        create: (_) => sl<AuthBloc>()..add(const AuthCheckStatusEvent()),
        child: AppScope(
          notifier: _settings,
          child: ListenableBuilder(
            listenable: _settings,
            builder: (context, _) => MaterialApp(
              navigatorKey: AppRouter.navigatorKey,
              title: 'M-IT Academy',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _settings.themeMode,
              locale: _settings.locale,
              home: const SplashScreen(),
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                final clampedScaler = mediaQuery.textScaler.clamp(
                  minScaleFactor: 1.0,
                  maxScaleFactor: 1.25,
                );
                return MediaQuery(
                  data: mediaQuery.copyWith(textScaler: clampedScaler),
                  child: child ?? const SizedBox.shrink(),
                );
              },
              onGenerateRoute: AppRouter.onGenerateRoute,
              onUnknownRoute: AppRouter.onUnknownRoute,
            ),
          ),
        ),
      ),
    );
  }
}

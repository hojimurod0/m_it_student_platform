import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/state/app_settings.dart';

class AppScope extends InheritedNotifier<AppSettings> {
  const AppScope({
    super.key,
    required AppSettings notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context. Make sure AppScope wraps the app.');
    return scope!.notifier!;
  }
}

extension AppScopeContext on BuildContext {
  AppSettings get appSettings => AppScope.of(this);
}

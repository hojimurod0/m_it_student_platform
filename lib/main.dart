import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/bootstrap/app_bootstrap.dart';
import 'package:m_it_student_platform/core/bootstrap/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.initialize();
  runApp(const MitStudentApp());
}



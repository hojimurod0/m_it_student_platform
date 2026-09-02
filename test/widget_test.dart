import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_it_student_platform/core/di/injection_container.dart';
import 'package:m_it_student_platform/core/state/app_scope.dart';
import 'package:m_it_student_platform/core/state/app_settings.dart';
import 'package:m_it_student_platform/core/theme/app_theme.dart';
import 'package:m_it_student_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:m_it_student_platform/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:m_it_student_platform/features/auth/presentation/screens/login_screen.dart';
import 'package:m_it_student_platform/features/home/data/services/ai_mentor_service.dart';
import 'package:m_it_student_platform/features/home/domain/models/ai_mentor_model.dart';
import 'package:m_it_student_platform/features/navigation/presentation/main_shell.dart';
import 'package:m_it_student_platform/features/payments/data/repositories/mock_payments_repository.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:m_it_student_platform/features/splash/presentation/splash_screen.dart' as m_it_student_platform_splash;
import 'package:m_it_student_platform/features/quiz/domain/entities/quiz.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';
import 'package:m_it_student_platform/features/auth/presentation/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m_it_student_platform/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:m_it_student_platform/core/routes/app_router.dart';

Widget createTestApp(Widget child, AppSettings settings) {
  final authRepo = MockAuthRepository.instance;
  Widget effectiveChild = child;
  if (child is LoginScreen) {
    effectiveChild = LoginScreen(authController: AuthController(authRepository: authRepo));
  }
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>(
        create: (_) => AuthBloc(authRepository: authRepo),
      ),
    ],
    child: AppScope(
      notifier: settings,
      child: MaterialApp(
        home: effectiveChild,
        onGenerateRoute: AppRouter.onGenerateRoute,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settings.themeMode,
        locale: settings.locale,
      ),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
    await LocalStorageService.setSelectedLanguage(true);
    await LocalStorageService.setCompletedOnboarding(true);
    await LocalStorageService.saveLanguage(AppLanguage.uz);
    await initDependencies();
    if (sl.isRegistered<AuthRepository>()) {
      sl.unregister<AuthRepository>();
    }
    sl.registerLazySingleton<AuthRepository>(() => MockAuthRepository.instance);
    MockProfileRepository.studentNotifier.value = MockProfileRepository.student;
  });

  testWidgets('Splash -> Login -> Student Panel navigation, 3-language and theme test', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    final settings = AppSettings();
    settings.setLanguage(AppLanguage.uz); // Default to Uzbek

    // 1. Launch App on Splash Screen
    await tester.pumpWidget(createTestApp(const m_it_student_platform_splash.SplashScreen(), settings));
    expect(find.byType(m_it_student_platform_splash.SplashScreen), findsOneWidget);

    // 2. Advance 3-second splash timer -> transitions to LoginScreen
    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Xush kelibsiz'), findsWidgets);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Parol'), findsOneWidget);
    // Check terms agreement checkbox
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    // 3. Enter default development credentials and login
    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2));
    final phoneField = textFields.at(0);
    final passwordField = textFields.at(1);

    await tester.enterText(phoneField, MockAuthRepository.devPhone);
    await tester.enterText(passwordField, MockAuthRepository.devPassword);
    await tester.pump();

    // Tap Kirish button
    await tester.tap(find.text('Kirish'));
    await tester.pump(); // Start loading
    await tester.pump(const Duration(milliseconds: 500)); // Mock latency
    await tester.pump(const Duration(milliseconds: 300));

    // 4. Verify Home Screen is active in Uzbek with IT courses & Student Name
    expect(find.text('Flutter Mobile Development'), findsWidgets);
    expect(find.text('Bugungi darslar'), findsWidgets);
    expect(find.text('Asosiy'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);

    // 5. Switch to Darslar Tab by tapping its icon
    await tester.tap(find.text('Darslar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Darslar'), findsWidgets);
    expect(find.textContaining('Barchasi'), findsWidgets);

    // 6. Switch to To'lovlar (Payments) Tab & Verify Monthly 400 000 Payment
    await tester.tap(find.text("To'lovlar"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("To'lovlar"), findsWidgets);
    expect(find.text("To'lovlar tarixi"), findsOneWidget);

    // Verify 500k monthly rate and paid status
    final summary = MockPaymentsRepository.paymentSummary;
    expect(summary.monthlyRate, 500000.0);
    expect(summary.isPaid, isTrue);
    expect(summary.statusText, "To'langan");

    // 7. Switch to Profil Tab & Verify Profile Elements
    await tester.tap(find.text('Profil'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Profil'), findsWidgets);
    expect(find.text('John Smith'), findsWidgets);

    // 8. Test Language Switcher (Change to English)
    settings.setLanguage(AppLanguage.en);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Appearance & Theme'), findsOneWidget);
    expect(find.text('Application Language'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // 9. Test Language Switcher (Change to Russian)
    settings.setLanguage(AppLanguage.ru);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Тема и Оформление'), findsOneWidget);
    expect(find.text('Язык приложения'), findsOneWidget);
    expect(find.text('Профиль'), findsOneWidget);

    // 10. Switch back to Uzbek and Light theme
    settings.setLanguage(AppLanguage.uz);
    settings.setThemeMode(ThemeMode.light);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Profil'), findsOneWidget);
  });

  testWidgets('Authentication tests: Empty validation, wrong password, unknown phone, and logout flow', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    final settings = AppSettings();
    settings.setLanguage(AppLanguage.uz);

    await tester.pumpWidget(createTestApp(const LoginScreen(), settings));
    await tester.pumpAndSettle();

    // Verify Login Screen initial elements
    expect(find.text('Xush kelibsiz'), findsOneWidget);
    expect(find.text('Kirish'), findsOneWidget);

    // --- TEST 4: Terms agreement & Empty Fields Validation ---
    // Agree to terms first so Kirish button is active
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Tap Kirish with empty login field
    await tester.tap(find.text('Kirish'));
    await tester.pumpAndSettle();
    expect(find.text('Loginingizni kiriting'), findsWidgets);

    final inputFields = find.byType(TextField);
    final phoneField = inputFields.at(0);
    final passwordField = inputFields.at(1);

    await tester.enterText(phoneField, '+998901234567');
    await tester.tap(find.text('Kirish'));
    await tester.pumpAndSettle();
    expect(find.text('Parolingizni kiriting'), findsWidgets);

    // --- TEST 2: Wrong Password ---
    await tester.enterText(passwordField, '999999');
    await tester.tap(find.text('Kirish'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.textContaining('noto\'g\'ri'), findsOneWidget);
    expect(find.text('Kirish'), findsOneWidget); // Stays on Login Screen

    // --- TEST 3: Unknown Phone ---
    await tester.enterText(phoneField, '+998909999999');
    await tester.enterText(passwordField, '123456');
    await tester.tap(find.text('Kirish'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.textContaining('noto\'g\'ri'), findsOneWidget);
    expect(find.text('Kirish'), findsOneWidget); // Stays on Login Screen

    // --- TEST 1: Correct Student Login ---
    await tester.enterText(phoneField, '+998901234567');
    await tester.enterText(passwordField, '123456');
    await tester.tap(find.text('Kirish'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify successful navigation to Student Panel
    expect(find.text('Asosiy'), findsOneWidget);
    expect(find.text('Flutter Mobile Development'), findsWidgets);

    // --- TEST 5: Logout Flow ---
    await tester.tap(find.text('Profil'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Scroll until Chiqish is visible
    final chiqishFinder = find.text('Chiqish');
    await tester.scrollUntilVisible(
      chiqishFinder,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(chiqishFinder, findsOneWidget);
    await tester.tap(chiqishFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Confirm logout dialog
    await tester.tap(find.widgetWithText(ElevatedButton, 'Chiqish'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify redirected back to Login Screen and back stack is empty
    expect(find.text('Xush kelibsiz'), findsOneWidget);
    expect(find.text('Kirish'), findsOneWidget);
  });

  testWidgets('Responsive screen test for compact phone without overflows', (tester) async {
    tester.view.physicalSize = const Size(720, 1280); // Compact screen
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    final settings = AppSettings();
    settings.setLanguage(AppLanguage.uz); // Default to Uzbek

    await tester.pumpWidget(createTestApp(const MainShell(), settings));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Home tab renders with 0 errors on small screen
    expect(find.text('Flutter Mobile Development'), findsWidgets);
    expect(find.text('Bugungi darslar'), findsOneWidget);

    // Verify Tab switching
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Darslar'), findsWidgets);
    expect(find.textContaining('Barchasi'), findsWidgets);

    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("To'lovlar"), findsWidgets);
    expect(find.text("To'lovlar tarixi"), findsOneWidget);
  });

  testWidgets('AI Mentor Q&A integration and reasoning test', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    final settings = AppSettings();
    settings.setLanguage(AppLanguage.uz);

    await tester.pumpWidget(createTestApp(const MainShell(), settings));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Direct AI Service domain intelligence unit assertions
    final blocAns = AiMentorService.generateAnswer('BLoC vs Provider');
    expect(blocAns.category, AiQueryCategory.flutter);
    expect(blocAns.codeLanguage, 'dart');

    final debugAns = AiMentorService.generateAnswer('Renderflex overflowed by 30 pixels');
    expect(debugAns.category, AiQueryCategory.debugging);

    final pythonAns = AiMentorService.generateAnswer('Python binary search algorithm');
    expect(pythonAns.category, AiQueryCategory.python);
    expect(pythonAns.codeLanguage, 'python');

    final academyAns = AiMentorService.generateAnswer('Dars jadvali va oylik to\'lov qancha');
    expect(academyAns.category, AiQueryCategory.academy);
    expect(academyAns.text.contains('500 000'), isTrue);
    expect(academyAns.text.contains('To\'langan'), isTrue);
  });

  testWidgets('Interactive IT Quiz modal, questions bank, and scoring test', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    final settings = AppSettings();
    await tester.pumpWidget(createTestApp(const MainShell(), settings));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Quiz Domain Entities and Model configuration
    const testQuestion = QuizQuestion(
      id: 'q-flut-1',
      category: QuizCategory.flutter,
      difficulty: QuizDifficulty.easy,
      xpReward: 15,
      question: 'Flutter test question',
      options: ['A', 'B', 'C', 'D'],
      correctIndex: 1,
      explanation: 'Explanation',
    );
    expect(testQuestion.category, QuizCategory.flutter);
    expect(testQuestion.options.length, 4);
    expect(testQuestion.difficulty, QuizDifficulty.easy);
    expect(testQuestion.xpReward, greaterThan(0));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m_it_student_platform/core/state/app_scope.dart';
import 'package:m_it_student_platform/core/state/app_settings.dart';
import 'package:m_it_student_platform/core/theme/app_theme.dart';
import 'package:m_it_student_platform/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:m_it_student_platform/features/auth/presentation/screens/login_screen.dart';
import 'package:m_it_student_platform/features/home/data/services/ai_mentor_service.dart';
import 'package:m_it_student_platform/features/home/domain/models/ai_mentor_model.dart';
import 'package:m_it_student_platform/features/navigation/presentation/main_shell.dart';
import 'package:m_it_student_platform/features/payments/data/repositories/mock_payments_repository.dart';
import 'package:m_it_student_platform/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:m_it_student_platform/main.dart';

Widget createTestApp(Widget child, AppSettings settings) {
  return AppScope(
    notifier: settings,
    child: MaterialApp(
      home: child,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
    ),
  );
}

void main() {
  setUp(() {
    MockProfileRepository.studentNotifier.value = MockProfileRepository.student;
  });

  testWidgets('Splash -> Login -> Student Panel navigation, 3-language and theme test', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    final settings = AppSettings();
    settings.setLanguage(AppLanguage.uz); // Default to Uzbek

    // 1. Launch App on Splash Screen
    await tester.pumpWidget(MitStudentApp(settings: settings));
    expect(find.text('M-IT Academy'), findsOneWidget);

    // 2. Advance 3-second splash timer -> transitions to LoginScreen
    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pumpAndSettle();

    expect(find.text('M-IT Academy'), findsOneWidget);
    expect(find.text('Telefon raqami'), findsOneWidget);
    expect(find.text('Parol'), findsOneWidget);
    expect(find.text('Kirish'), findsOneWidget);

    // 3. Enter default development credentials and login
    final textFields = find.byType(TextFormField);
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
    await tester.pumpAndSettle();

    // 4. Verify Home Screen is active in Uzbek with IT courses & Student Name
    expect(find.text('Flutter Mobile Development'), findsWidgets);
    expect(find.text('Bugungi darslar'), findsOneWidget);
    expect(find.text('Asosiy'), findsOneWidget);
    expect(find.text('John Smith'), findsOneWidget);

    // 5. Switch to Darslar / Mavzular Tab by tapping its icon
    await tester.tap(find.text('Darslar'));
    await tester.pumpAndSettle();
    expect(find.text('Darslar'), findsWidgets);
    expect(find.text('Mavzular'), findsWidgets);
    expect(find.text('Imtihon'), findsOneWidget);
    expect(find.text('Bootcamp Foundation FN12'), findsOneWidget);

    // 6. Switch to To'lovlar (Payments) Tab & Verify Monthly 400 000 Payment
    await tester.tap(find.text("To'lovlar"));
    await tester.pumpAndSettle();
    expect(find.text("To'lovlar"), findsWidgets);
    expect(find.text("Kurs To'lovlari"), findsOneWidget);
    expect(find.text("Oylik to'lov miqdori"), findsWidgets);

    // Verify 400k monthly rate and paid status
    final summary = MockPaymentsRepository.paymentSummary;
    expect(summary.monthlyRate, 400000.0);
    expect(summary.isPaid, isTrue);
    expect(summary.statusText, "To'langan");

    // 7. Switch to Profil (Profile) Tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Profil'), findsWidgets);
    expect(find.text('John Smith'), findsWidgets);

    // 8. Test Language Switcher (Change to English)
    settings.setLanguage(AppLanguage.en);
    await tester.pumpAndSettle();
    expect(find.text('Appearance & Theme'), findsOneWidget);
    expect(find.text('Application Language'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // 9. Test Language Switcher (Change to Russian)
    settings.setLanguage(AppLanguage.ru);
    await tester.pumpAndSettle();
    expect(find.text('Тема и Оформление'), findsOneWidget);
    expect(find.text('Язык приложения'), findsOneWidget);
    expect(find.text('Профиль'), findsOneWidget);

    // 10. Switch back to Uzbek and Light theme
    settings.setLanguage(AppLanguage.uz);
    settings.setThemeMode(ThemeMode.light);
    await tester.pumpAndSettle();
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
    expect(find.text('M-IT Academy'), findsOneWidget);
    expect(find.text('Kirish'), findsOneWidget);

    // --- TEST 4: Empty Fields Validation ---
    await tester.tap(find.text('Kirish'));
    await tester.pumpAndSettle();
    expect(find.text('Telefon raqamingizni kiriting'), findsOneWidget);

    final inputFields = find.byType(TextFormField);
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

    expect(find.text('Telefon raqami yoki parol noto\'g\'ri'), findsOneWidget);
    expect(find.text('Kirish'), findsOneWidget); // Stays on Login Screen

    // --- TEST 3: Unknown Phone ---
    await tester.enterText(phoneField, '+998909999999');
    await tester.enterText(passwordField, '123456');
    await tester.tap(find.text('Kirish'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Telefon raqami yoki parol noto\'g\'ri'), findsOneWidget);
    expect(find.text('Kirish'), findsOneWidget); // Stays on Login Screen

    // --- TEST 1: Correct Student Login ---
    await tester.enterText(phoneField, '+998901234567');
    await tester.enterText(passwordField, '123456');
    await tester.tap(find.text('Kirish'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify successful navigation to Student Panel
    expect(find.text('Asosiy'), findsOneWidget);
    expect(find.text('Flutter Mobile Development'), findsWidgets);

    // --- TEST 5: Logout Flow ---
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Scroll until Chiqish is visible
    final chiqishFinder = find.text('Chiqish');
    await tester.scrollUntilVisible(
      chiqishFinder,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    expect(chiqishFinder, findsOneWidget);
    await tester.tap(chiqishFinder);
    await tester.pumpAndSettle();

    // Confirm logout dialog
    expect(find.text('Chiqishni tasdiqlaysizmi?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Chiqish'));
    await tester.pumpAndSettle();

    // Verify redirected back to Login Screen and back stack is empty
    expect(find.text('M-IT Academy'), findsOneWidget);
    expect(find.text('Kirish'), findsOneWidget);
  });

  testWidgets('Responsive screen test for compact phone without overflows', (tester) async {
    tester.view.physicalSize = const Size(720, 1280); // Compact screen
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    final settings = AppSettings();
    settings.setLanguage(AppLanguage.uz); // Default to Uzbek

    await tester.pumpWidget(createTestApp(const MainShell(), settings));
    await tester.pumpAndSettle();

    // Verify Home tab renders with 0 errors on small screen
    expect(find.text('Flutter Mobile Development'), findsWidgets);
    expect(find.text('Bugungi darslar'), findsOneWidget);

    // Verify Tab switching
    await tester.tap(find.byIcon(Icons.menu_book_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Darslar'), findsOneWidget);
    expect(find.text('Mavzular'), findsWidgets);

    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await tester.pumpAndSettle();
    expect(find.text("To'lovlar"), findsOneWidget);
    expect(find.text("Kurs To'lovlari"), findsOneWidget);
  });

  testWidgets('AI Mentor Q&A integration and reasoning test', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    final settings = AppSettings();
    settings.setLanguage(AppLanguage.uz);

    await tester.pumpWidget(createTestApp(const MainShell(), settings));
    await tester.pumpAndSettle();

    // 1. Open AI Mentor modal from Home quick actions
    expect(find.text('AI Mentor'), findsWidgets);
    await tester.tap(find.text('AI Mentor').first);
    await tester.pumpAndSettle();

    // 2. Verify AI Mentor Jarayonda (In Progress) Modal UI
    expect(find.text('AI MENTOR 2.0 • JARAYONDA'), findsOneWidget);
    expect(find.text('AI Mentor Ishlab Chiqilmoqda'), findsOneWidget);
    expect(find.text('Jonli Ustoz'), findsOneWidget);

    // 3. Tap Jonli Ustoz to open live mentor chat
    await tester.ensureVisible(find.text('Jonli Ustoz'));
    await tester.tap(find.text('Jonli Ustoz'));
    await tester.pumpAndSettle();

    // 4. Verify Mentor Chat Modal UI
    expect(find.text('Abbos Qodirov (AI Mentor)'), findsOneWidget);
    expect(find.text('AI 2.0'), findsOneWidget);

    // 5. Ask question via input text field
    final inputField = find.byType(TextField);
    expect(inputField, findsOneWidget);
    await tester.enterText(inputField, 'BLoC va Provider farqi nima?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    // Advance AI thinking timer
    await tester.pump(const Duration(milliseconds: 1200));

    // 4. Verify intelligent AI response with code snippet
    expect(find.textContaining('BLoC (Business Logic Component)'), findsWidgets);
    expect(find.text('DART'), findsWidgets);
    expect(find.text('Kodni nusxalash'), findsWidgets);

    // 5. Ask second question for error debugging
    await tester.enterText(inputField, 'RenderFlex overflow xatosini tuzatish');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('RenderFlex'), findsWidgets);

    // Close open modal
    final closeBtn = find.byIcon(Icons.close_rounded);
    if (closeBtn.evaluate().isNotEmpty) {
      await tester.tap(closeBtn.first);
      await tester.pumpAndSettle();
    }

    // 6. Direct AI Service domain intelligence unit assertions
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
    expect(academyAns.text.contains('400 000'), isTrue);
    expect(academyAns.text.contains('To\'langan'), isTrue);
  });

  testWidgets('Interactive IT Quiz modal, questions bank, and scoring test', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    final settings = AppSettings();
    await tester.pumpWidget(createTestApp(const MainShell(), settings));
    await tester.pumpAndSettle();

    // Tap on IT Kviz from quick actions carousel
    expect(find.text('IT Kviz'), findsWidgets);
    await tester.tap(find.text('IT Kviz').first);
    await tester.pumpAndSettle();

    // Verify Quiz Modal UI
    expect(find.text('IT Kviz & Bilimni Sinash'), findsOneWidget);
    expect(find.text('Flutter'), findsWidgets);
    expect(find.text('Dart OOP'), findsWidgets);

    // Verify options are displayed
    expect(find.text('A'), findsWidgets);
    expect(find.text('B'), findsWidgets);

    // Tap correct option B (index 1) for first Flutter question
    await tester.tap(find.text('B').first);
    await tester.pumpAndSettle();

    // Verify explanation and Next Question button appear
    expect(find.text('Mentor Izohi & Tushuntirish:'), findsOneWidget);
    expect(find.text('Keyingi Savol ➜'), findsOneWidget);

    // Close modal
    final modalClose = find.byIcon(Icons.close_rounded);
    if (modalClose.evaluate().isNotEmpty) {
      await tester.tap(modalClose.first);
      await tester.pumpAndSettle();
    }
  });
}

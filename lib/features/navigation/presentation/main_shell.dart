import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m_it_student_platform/core/localization/app_strings.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/custom_bottom_nav.dart';
import 'package:m_it_student_platform/core/widgets/network_status_banner.dart';
import 'package:m_it_student_platform/core/widgets/ui/mit_toast.dart';
import 'package:m_it_student_platform/features/home/presentation/screens/home_screen.dart';
import 'package:m_it_student_platform/features/lessons/presentation/screens/lessons_screen.dart';
import 'package:m_it_student_platform/features/payments/presentation/screens/payments_screen.dart';
import 'package:m_it_student_platform/features/profile/presentation/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isOffline = false;
  DateTime? _lastBackPressTime;
  Timer? _connectivityTimer;

  static bool get _isTestEnvironment {
    try {
      return !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!_isTestEnvironment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkConnectivity();
      });
      _connectivityTimer = Timer.periodic(const Duration(seconds: 25), (_) {
        _checkConnectivity();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnectivity();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivityTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    if (kIsWeb) return;
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (mounted && _isOffline != !online) {
        setState(() => _isOffline = !online);
      }
    } catch (_) {
      // In test environments or offline state, update gracefully
      if (mounted && !_isOffline) {
        setState(() => _isOffline = true);
      }
    }
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    AppHaptics.selection();
    setState(() => _currentIndex = index);
  }

  void _handlePopInvoked(bool didPop, dynamic result) {
    if (didPop) return;

    if (_currentIndex != 0) {
      _onTabSelected(0);
      return;
    }

    final now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      AppHaptics.light();
      MitToast.info(context, context.tr('pressAgainToExit'));
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePopInvoked,
      child: Scaffold(
        body: Column(
          children: [
            NetworkStatusBanner(
              isOffline: _isOffline,
              onRetry: () async {
                AppHaptics.light();
                await _checkConnectivity();
                if (!context.mounted) return;
                if (!_isOffline) {
                  MitToast.success(context, 'Internetga ulandi');
                }
              },
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  HomeScreen(onNavigateToTab: _onTabSelected),
                  const LessonsScreen(),
                  const PaymentsScreen(),
                  const ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: RepaintBoundary(
          child: CustomBottomNav(
            currentIndex: _currentIndex,
            onTap: _onTabSelected,
          ),
        ),
      ),
    );
  }
}



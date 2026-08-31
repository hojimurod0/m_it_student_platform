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

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final bool _isOffline = false;
  DateTime? _lastBackPressTime;

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
              onRetry: () {
                AppHaptics.light();
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



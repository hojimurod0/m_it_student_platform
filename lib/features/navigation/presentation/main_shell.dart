import 'package:flutter/material.dart';
import 'package:m_it_student_platform/core/utils/haptics.dart';
import 'package:m_it_student_platform/core/widgets/custom_bottom_nav.dart';
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

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    AppHaptics.selection();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onNavigateToTab: _onTabSelected),
          const LessonsScreen(),
          const PaymentsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: RepaintBoundary(
        child: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
        ),
      ),
    );
  }
}


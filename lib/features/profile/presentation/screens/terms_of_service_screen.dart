import 'package:flutter/material.dart';
import 'package:m_it_student_platform/features/profile/presentation/screens/privacy_policy_screen.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PrivacyPolicyScreen(initialTab: 1);
  }
}

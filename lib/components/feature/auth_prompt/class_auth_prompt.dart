import 'package:flutter/material.dart';
import 'auth_prompt_widget.dart';

class ClassAuthPrompt extends StatelessWidget {
  final String selectedLanguage;
  final bool isDark;

  const ClassAuthPrompt({
    super.key,
    required this.selectedLanguage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AuthPromptWidget(
      title: 'Join Classes',
      description: 'Sign in to access your classes, view schedules, and connect with your teachers and classmates.',
      iconName: 'class',
      isDark: isDark,
      onSignIn: () => Navigator.pushNamed(context, '/login'),
      onSignUp: () => Navigator.pushNamed(context, '/signup'),
    );
  }
}

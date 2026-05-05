import 'package:flutter/material.dart';
import 'auth_prompt_widget.dart';

class AssignmentAuthPrompt extends StatelessWidget {
  final String selectedLanguage;
  final bool isDark;

  const AssignmentAuthPrompt({
    super.key,
    required this.selectedLanguage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AuthPromptWidget(
      title: 'View Assignments',
      description: 'Sign in to access your assignments, submit work, track deadlines, and receive feedback from your teachers.',
      iconName: 'assignment',
      isDark: isDark,
      onSignIn: () => Navigator.pushNamed(context, '/login'),
      onSignUp: () => Navigator.pushNamed(context, '/signup'),
    );
  }
}

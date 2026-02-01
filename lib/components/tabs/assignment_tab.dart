import 'package:flutter/material.dart';
import '../utils/localization.dart';

class AssignmentTab extends StatelessWidget {
  final String role;
  final String selectedLanguage;

  const AssignmentTab({super.key, required this.role, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    final textKey = role == 'teacher' ? 'assignmentsTeacher' : 'assignmentsStudent';
    return Center(
      child: Text(
        Localization.text(selectedLanguage, textKey),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/localization.dart';

class HomeTab extends StatelessWidget {
  final String role; // 'teacher' or 'student'
  final String selectedLanguage;

  const HomeTab({super.key, required this.role, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    final textKey = role == 'teacher' ? 'homeScreenTeacher' : 'homeScreenStudent';
    return Center(
      child: Text(
        Localization.text(selectedLanguage, textKey),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

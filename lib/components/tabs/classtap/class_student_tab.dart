import 'package:flutter/material.dart';
import '../../utils/localization.dart';

class ClassStudentTab extends StatelessWidget {
  final String language;

  const ClassStudentTab({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Localization.text(language, "welcomeDesc"),
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
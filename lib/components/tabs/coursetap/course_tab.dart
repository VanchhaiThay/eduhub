import 'package:flutter/material.dart';
import '../../utils/localization.dart';

class CourseTab extends StatelessWidget {
  final String selectedLanguage;

  const CourseTab({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Localization.text(selectedLanguage, 'coursePage'),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

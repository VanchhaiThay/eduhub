import 'package:flutter/material.dart';
import '../../../utils/localization.dart';

class HomeTeacherTab extends StatelessWidget {
  final String language;

  const HomeTeacherTab({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Localization.text(language, 'homeScreenTeacher'),
        style: const TextStyle(fontSize: 22),
      ),
    );
  }
}

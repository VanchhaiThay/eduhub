import 'package:flutter/material.dart';
import '../../utils/localization.dart';

class ClassTeacherTab extends StatelessWidget {
  final String language;

  const ClassTeacherTab({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Localization.text(language, 'classesTeacher'),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

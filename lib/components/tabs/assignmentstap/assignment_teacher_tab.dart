import 'package:flutter/material.dart';
import '../../utils/localization.dart';

class AssignmentTeacherTab extends StatelessWidget {
  final String language;

  const AssignmentTeacherTab({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Localization.text(language, 'assignmentsTeacher'),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../utils/localization.dart';

class AssignmentStudentTab extends StatelessWidget {
  final String language;

  const AssignmentStudentTab({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Localization.text(language, 'assignmentsStudent'),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

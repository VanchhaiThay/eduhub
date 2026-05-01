import 'package:flutter/material.dart';
import '../../../utils/localization.dart';

class AssignmentStudentTab extends StatefulWidget {
  final String? assignmentId;
  final String language;

  const AssignmentStudentTab({
    super.key,
    this.assignmentId,
    required this.language,
  });

  @override
  State<AssignmentStudentTab> createState() => _AssignmentStudentTabState();
}

class _AssignmentStudentTabState extends State<AssignmentStudentTab> {
  @override
  void initState() {
    super.initState();
    if (widget.assignmentId != null) {
      // Load assignment details using assignmentId
      _loadAssignmentDetails();
    }
  }

  Future<void> _loadAssignmentDetails() async {
    // TODO: Implement assignment loading logic
    // Fetch assignment data from Firestore using widget.assignmentId
    // Display assignment details instead of placeholder text
  }

  @override
  Widget build(BuildContext context) {
    if (widget.assignmentId != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Assignment'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Center(
      child: Text(
        Localization.text(widget.language, 'assignmentsStudent'),
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../utils/localization.dart';
import '../../../services/assignment_service.dart';
import '../../../services/assignment_completion_service.dart';
import 'assignmentPreviewpage.dart';
import 'assignment_done_page.dart';

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
  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() => _isLoading = true);

    try {
      final assignments = await AssignmentService.getAllAssignments();
      if (mounted) {
        setState(() {
          _assignments = assignments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load assignments: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToAssignment(Map<String, dynamic> assignment) async {
    // Debug logging
    print('StudentTab - Navigating to assignment: $assignment');

    try {
      // Fetch full assignment details with questions
      final assignmentId = assignment['id'];
      if (assignmentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Assignment ID not found"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if assignment is already completed
      final isCompleted =
          await AssignmentCompletionService.isAssignmentCompleted(assignmentId);

      if (isCompleted) {
        // Show Assignment Done page
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AssignmentDonePage(
                assignmentTitle: assignment['title'] ?? 'Untitled Assignment',
                assignmentId: assignmentId,
              ),
            ),
          );
        }
        return;
      }

      final fullAssignment =
          await AssignmentService.getAssignment(assignmentId);
      print('StudentTab - Full assignment fetched: $fullAssignment');

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssignmentPreviewPage(
              data: fullAssignment,
              isTeacherPreview: false,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load assignment: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAssignmentCard(Map<String, dynamic> assignment) {
    final String title = assignment['title'] ?? 'Untitled Assignment';
    final String language = assignment['language'] ?? 'en';
    final int questionCount = assignment['questions']?.length ?? 0;
    final assignmentId = assignment['id'];

    return FutureBuilder<bool>(
      future: AssignmentCompletionService.isAssignmentCompleted(assignmentId),
      builder: (context, snapshot) {
        final isCompleted = snapshot.data ?? false;

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => _navigateToAssignment(assignment),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: isCompleted
                      ? [
                          Colors.green.withOpacity(0.1),
                          Colors.green.withOpacity(0.05),
                        ]
                      : [
                          const Color(0xFF38A39D).withOpacity(0.1),
                          const Color(0xFF38A39D).withOpacity(0.05),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green
                              : const Color(0xFF38A39D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isCompleted ? Icons.check_circle : Icons.assignment,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? Colors.green
                                    : const Color(0xFF38A39D),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$questionCount questions • $language',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'COMPLETED',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color:
                          isCompleted ? Colors.green : const Color(0xFF38A39D),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isCompleted ? 'View Assignment' : 'Start Assignment',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.assignmentId != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Assignment'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF0EBF8),
      body: RefreshIndicator(
        onRefresh: _loadAssignments,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _assignments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No assignments available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back later for new assignments',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _assignments.length,
                    itemBuilder: (context, index) {
                      return _buildAssignmentCard(_assignments[index]);
                    },
                  ),
      ),
    );
  }
}

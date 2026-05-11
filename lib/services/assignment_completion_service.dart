import 'package:shared_preferences/shared_preferences.dart';

class AssignmentCompletionService {
  static const String _completedAssignmentsKey = 'completed_assignments';

  // Check if an assignment is completed
  static Future<bool> isAssignmentCompleted(int assignmentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedAssignments = prefs.getStringList(_completedAssignmentsKey) ?? [];
      return completedAssignments.contains(assignmentId.toString());
    } catch (e) {
      print('Error checking assignment completion: $e');
      return false;
    }
  }

  // Mark an assignment as completed
  static Future<void> markAssignmentCompleted(int assignmentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedAssignments = prefs.getStringList(_completedAssignmentsKey) ?? [];
      
      if (!completedAssignments.contains(assignmentId.toString())) {
        completedAssignments.add(assignmentId.toString());
        await prefs.setStringList(_completedAssignmentsKey, completedAssignments);
        print('Assignment $assignmentId marked as completed');
      }
    } catch (e) {
      print('Error marking assignment as completed: $e');
    }
  }

  // Get all completed assignment IDs
  static Future<List<int>> getCompletedAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedAssignments = prefs.getStringList(_completedAssignmentsKey) ?? [];
      return completedAssignments.map((id) => int.tryParse(id) ?? 0).where((id) => id > 0).toList();
    } catch (e) {
      print('Error getting completed assignments: $e');
      return [];
    }
  }

  // Clear all completed assignments (for testing/reset)
  static Future<void> clearAllCompletedAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_completedAssignmentsKey);
      print('All completed assignments cleared');
    } catch (e) {
      print('Error clearing completed assignments: $e');
    }
  }

  // Get completion count
  static Future<int> getCompletedCount() async {
    try {
      final completed = await getCompletedAssignments();
      return completed.length;
    } catch (e) {
      print('Error getting completion count: $e');
      return 0;
    }
  }
}

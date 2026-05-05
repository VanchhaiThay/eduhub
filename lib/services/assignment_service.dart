import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AssignmentService {
  static const String baseUrl =
      'http://10.0.2.2:3000/api'; // Use 10.0.2.2 for Android emulator, 127.0.0.1 for iOS simulator

  // Create new assignment
  static Future<Map<String, dynamic>> createAssignment({
    required String title,
    required String language,
    List<Map<String, dynamic>>? questions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assignments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'language': language,
          'questions': questions ?? [],
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create assignment: ${response.body}');
      }
    } catch (e) {
      print('AssignmentService Error: $e');
      print('URL attempted: $baseUrl/assignments');
      throw Exception('Error creating assignment: $e');
    }
  }

  // Get all assignments
  static Future<List<Map<String, dynamic>>> getAllAssignments() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/assignments'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch assignments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching assignments: $e');
    }
  }

  // Get single assignment by ID
  static Future<Map<String, dynamic>> getAssignment(int assignmentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assignments/$assignmentId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch assignment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching assignment: $e');
    }
  }

  // Update assignment
  static Future<Map<String, dynamic>> updateAssignment(
    int assignmentId, {
    required String title,
    String? description,
    String language = 'en',
    List<String>? imageUrls,
    List<Map<String, dynamic>>? questions,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/assignments/$assignmentId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'description': description,
          'language': language,
          'image_urls': imageUrls ?? [],
          'questions': questions ?? [],
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update assignment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating assignment: $e');
    }
  }

  // Delete assignment
  static Future<void> deleteAssignment(int assignmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/assignments/$assignmentId'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete assignment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting assignment: $e');
    }
  }

  // Clear all assignments for a teacher
  static Future<Map<String, dynamic>> clearTeacherAssignments(
    String teacherId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/assignments/teacher/$teacherId/clear'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to clear assignments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error clearing assignments: $e');
    }
  }

  // Get current user ID
  static String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}

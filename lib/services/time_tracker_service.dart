import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class TimeTrackerService {
  // Start time tracking
  Future<Map<String, dynamic>> startTimeTracking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('postgres_user_id');

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/time-tracker/start'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId.toString(),
        },
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to start time tracking');
      }
    } catch (e) {
      throw Exception('Start time tracking error: $e');
    }
  }

  // End time tracking
  Future<Map<String, dynamic>> endTimeTracking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('postgres_user_id');

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/time-tracker/end'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to end time tracking');
      }
    } catch (e) {
      throw Exception('End time tracking error: $e');
    }
  }

  // Get tracking history
  Future<Map<String, dynamic>> getTrackingHistory({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('postgres_user_id');

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/api/time-tracker/history?limit=$limit&offset=$offset',
        ),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to get tracking history');
      }
    } catch (e) {
      throw Exception('Get tracking history error: $e');
    }
  }

  // Get current active session
  Future<Map<String, dynamic>?> getActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('postgres_user_id');

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/time-tracker/active'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['activeSession'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to get active session');
      }
    } catch (e) {
      throw Exception('Get active session error: $e');
    }
  }

  // Get total time spent today
  Future<Map<String, dynamic>> getTotalTimeToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('postgres_user_id');

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/time-tracker/total-today'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['error'] ?? 'Failed to get total time spent today',
        );
      }
    } catch (e) {
      throw Exception('Get total time today error: $e');
    }
  }

  // Get weekly time tracking data
  Future<Map<String, dynamic>> getWeeklyTimeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('postgres_user_id');

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/time-tracker/weekly'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId.toString(),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(
          error['error'] ?? 'Failed to get weekly time data',
        );
      }
    } catch (e) {
      throw Exception('Get weekly time data error: $e');
    }
  }
}

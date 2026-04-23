import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Update this to your backend URL
  // For Android emulator: use 10.0.2.2 instead of localhost
  // For iOS simulator: use localhost or 127.0.0.1
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  final http.Client _client = http.Client();

  Future<Map<String, dynamic>> signup({
    required String firebaseUid,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firebaseUid': firebaseUid,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> getUser(String firebaseUid) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/users/$firebaseUid'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'User not found');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
import 'package:eduhub/auth/forgot_password.dart';
import 'package:eduhub/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:eduhub/utils/auth_flow_manager.dart';
import 'package:eduhub/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/home/home.dart';
import '../main.dart';
import '../services/time_tracker_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false; // For the eye icon

  final ApiService _apiService = ApiService();
  final TimeTrackerService _timeTrackerService = TimeTrackerService();

  Future<void> login() async {
    if (isLoading) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please fill in all fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      // First login with Firebase
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) throw Exception("User profile not found");

      // Then sync with backend (signup if doesn't exist, then login)
      int? postgresUserId;
      try {
        final backendResponse = await _apiService.login(
          email: email,
          password: password,
        );
        postgresUserId = backendResponse['user']['id'];
      } catch (e) {
        // User doesn't exist in PostgreSQL, create them
        if (e.toString().contains('Invalid credentials')) {
          debugPrint('User not in PostgreSQL, syncing...');
          final userData = doc.data()!;
          final signupResponse = await _apiService.signup(
            firebaseUid: credential.user!.uid,
            firstName: userData['firstName'] ?? '',
            lastName: userData['lastName'] ?? '',
            email: email,
            password: password,
            role: userData['role'] ?? 'student',
          );
          postgresUserId = signupResponse['user']['id'];
        } else {
          rethrow;
        }
      }

      // Save postgres user ID for tracking
      if (postgresUserId != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('postgres_user_id', postgresUserId);

        // Start time tracking after successful login
        try {
          await _timeTrackerService.startTimeTracking();
          debugPrint('Time tracking started for user: $postgresUserId');
        } catch (e) {
          debugPrint('Failed to start time tracking after login: $e');
        }
      }

      // Check notification permission
      final notificationStatus = await Permission.notification.status;
      debugPrint('Notification permission status: $notificationStatus');

      if (notificationStatus.isGranted) {
        // Local Notification
        debugPrint('Attempting to show login notification...');
        try {
          await flutterLocalNotificationsPlugin.show(
            id: 0,
            title: 'Welcome Back!',
            body: 'Hello, ${doc['firstName']}! Glad to see you again.',
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'login_channel',
                'Login Notifications',
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
          );
          debugPrint('Login notification sent successfully');
        } catch (e) {
          debugPrint('Error showing notification: $e');
        }
      } else {
        debugPrint('Notification permission not granted');
        // Request permission
        await Permission.notification.request();
      }

      if (!mounted) return;
      await AuthFlowManager.setStayOnHomeAfterLogout(false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(initialNotification: 1),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Authentication failed");
    } catch (e) {
      _showError("Error: $e");
      debugPrint('Login error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Test notification function for debugging
  Future<void> _testNotification() async {
    debugPrint('Testing notification...');
    try {
      await flutterLocalNotificationsPlugin.show(
        id: 999,
        title: 'Test Notification',
        body: 'This is a test notification to verify it works!',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'login_channel',
            'Login Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
      debugPrint('Test notification sent');
    } catch (e) {
      debugPrint('Test notification error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF38A39D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF38A39D),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // Animated or simple asset image
                Image.asset("assets/images/login.png", width: 180),
                const SizedBox(height: 30),

                // Header Text
                const Text(
                  "Welcome to EduHub",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sign in to continue your learning",
                  // ignore: deprecated_member_use
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                // Glassmorphic Login Card
                Container(
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    // ignore: deprecated_member_use
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      // Email Field
                      TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(
                          "Email",
                          Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      TextField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        style: const TextStyle(color: Colors.white),
                        decoration:
                            _buildInputDecoration(
                              "Password",
                              Icons.lock_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => isPasswordVisible = !isPasswordVisible,
                                ),
                              ),
                            ),
                      ),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          ),
                          child: Text(
                            "Forgot Password?",
                            // ignore: deprecated_member_use
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF38A39D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF38A39D),
                                  ),
                                )
                              : const Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Footer: Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ignore: deprecated_member_use
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70, size: 22),
      // ignore: deprecated_member_use
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }
}

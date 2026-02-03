import 'package:eduhub/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../components/home.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    try {
      // Firebase login
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!doc.exists) throw Exception("User data not found");

      // Send local notification
      await flutterLocalNotificationsPlugin.show(
        id: 0,
        title: 'Login Successful',
        body: 'Welcome back, ${doc['firstName']}!',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'login_channel',
            'Login Notifications',
            channelDescription: 'Notifications for login events',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
          ),
        ),
      );

      // Navigate to HomePage with initial notification
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(initialNotification: 1),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed")));
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF38A39D),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("assets/images/login.png", width: 200),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    // ignore: deprecated_member_use
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  enabled: !isLoading,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    // ignore: deprecated_member_use
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF38A39D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF38A39D),
                            ),
                          )
                        : const Text("Login"),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white),
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
}

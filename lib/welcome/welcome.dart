import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eduhub/components/home.dart';
import 'package:eduhub/auth/signin.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();

    // Wait 3 seconds then navigate
    Timer(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFED811),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Logo circle
            Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                color: Color(0xFF2CB5AE),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                "E",
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "EduHub",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Hub for Students & Teachers",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(strokeWidth: 2),
                SizedBox(width: 12),
                Text("Loading"),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

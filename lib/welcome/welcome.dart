import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eduhub/components/home/home.dart';
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
      if (!mounted) return; // Check if widget is still in tree

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(initialNotification: 0),
          ),
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
    // Detect Brightness
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Toggle background: Yellow for Light, Deep Grey/Black for Dark
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFFED811),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Logo circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                // We keep the Teal brand color, or dim it slightly for dark mode
                color: isDark ? const Color(0xFF269A94) : const Color(0xFF2CB5AE),
                shape: BoxShape.circle,
                boxShadow: isDark 
                  ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)] 
                  : null,
              ),
              alignment: Alignment.center,
              child: const Text(
                "E",
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // "E" stays white in both modes
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "EduHub",
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black, // Dynamic text
              ),
            ),
            Text(
              "Hub for Students & Teachers",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87, // Subtle contrast
              ),
            ),
            
            const Spacer(),

            // Loading Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  // Teal in light mode, White/Amber in dark mode
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? Colors.white : const Color(0xFF2CB5AE),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Loading",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
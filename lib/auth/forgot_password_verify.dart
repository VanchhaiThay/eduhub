import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'set_new_password.dart';

class ForgotPasswordVerify extends StatefulWidget {
  const ForgotPasswordVerify({super.key});

  @override
  State<ForgotPasswordVerify> createState() => _ForgotPasswordVerifyState();
}

class _ForgotPasswordVerifyState extends State<ForgotPasswordVerify> {
  final emailController = TextEditingController();
  bool isLoading = false;

  Future<void> checkEmail() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => isLoading = true);

    try {
      // Look for the email in your Firestore 'users' collection
      final query = await FirebaseFirestore.instance
          .collection("users")
          .where("email", isEqualTo: email)
          .get();

      if (query.docs.isNotEmpty) {
        // Email exists! Navigate to the "Set New Password" page
        String userId = query.docs.first.id;
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SetNewPasswordPage(userId: userId, email: email),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email not found. Please sign up.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF38A39D),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text("Verify Email", 
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Enter your email",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : checkEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF38A39D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: isLoading ? const CircularProgressIndicator() : const Text("Verify Account"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
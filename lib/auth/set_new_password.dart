import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SetNewPasswordPage extends StatefulWidget {
  final String userId;
  final String email;
  const SetNewPasswordPage({super.key, required this.userId, required this.email});

  @override
  State<SetNewPasswordPage> createState() => _SetNewPasswordPageState();
}

class _SetNewPasswordPageState extends State<SetNewPasswordPage> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> updatePassword() async {
    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
      return;
    }

    setState(() => isLoading = true);

    try {
      // Update the password field in Firestore
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update({"password": newPasswordController.text.trim()});

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Success"),
        content: const Text("Your password has been changed successfully. Please login again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("Go to Login"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF38A39D),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            const Icon(Icons.lock_reset_rounded, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            Text("Setting password for ${widget.email}", textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 30),
            _buildField(newPasswordController, "New Password"),
            const SizedBox(height: 15),
            _buildField(confirmPasswordController, "Confirm Password"),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF38A39D),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: isLoading ? const CircularProgressIndicator() : const Text("Update Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }
}
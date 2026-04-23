import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String role = "student"; 
  bool isLoading = false;
  bool isPasswordVisible = false;

  final ApiService _apiService = ApiService();

  Future<void> signup() async {
    if (isLoading) return;

    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      _showStatus("Please fill all fields", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      // Step 1: Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final String firebaseUid = userCredential.user!.uid;
      final String email = emailController.text.trim();
      final String password = passwordController.text.trim();
      final String firstName = firstNameController.text.trim();
      final String lastName = lastNameController.text.trim();

      // Step 2: Store in PostgreSQL via Node.js backend (Primary storage)
      try {
        await _apiService.signup(
          firebaseUid: firebaseUid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          role: role,
        );
      } catch (e) {
        // Log error but continue - Firebase storage still works as backup
        debugPrint('PostgreSQL storage error: $e');
      }

      // Step 3: Store in Firebase Firestore (Secondary storage)
      await FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUid)
          .set({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "role": role,
        "createdAt": Timestamp.now(),
      });

      if (!mounted) return;
      _showStatus("Account created successfully!");
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showStatus(e.message ?? "Signup failed", isError: true);
    } catch (e) {
      _showStatus("Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showStatus(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Professional Role Selector Component
  Widget buildRoleButton(String value, String label, IconData icon) {
    bool isSelected = role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => role = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              // ignore: deprecated_member_use
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF38A39D) : Colors.white70,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF38A39D) : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF38A39D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Join EduHub",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Create an account to start your journey",
                // ignore: deprecated_member_use
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Image(image: AssetImage("assets/images/signup.png"),width: 170,),
                ],
              ),

              // Glassmorphic Signup Form
              Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  // ignore: deprecated_member_use
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First & Last Name
                    Row(
                      children: [
                        Expanded(child: _buildTextField(firstNameController, "First Name", Icons.person_outline)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildTextField(lastNameController, "Last Name", null)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(emailController, "Email Address", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 20),
                    _buildTextField(
                      passwordController, 
                      "Password", 
                      Icons.lock_outline, 
                      isPassword: true,
                    ),
                    const SizedBox(height: 25),
                    
                    const Text("I am a:", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 12),
                    
                    // Professional Role Toggles
                    Row(
                      children: [
                        buildRoleButton("student", "Student", Icons.school_outlined),
                        const SizedBox(width: 15),
                        buildRoleButton("teacher", "Teacher", Icons.co_present_outlined),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF38A39D),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF38A39D)))
                            : const Text("CREATE ACCOUNT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Footer
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ignore: deprecated_member_use
                    Text("Already have an account? ", style: TextStyle(color: Colors.white.withOpacity(0.7))),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData? icon, {bool isPassword = false, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white70, size: 20) : null,
        suffixIcon: isPassword ? IconButton(
          icon: Icon(isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70, size: 18),
          onPressed: () => setState(() => isPasswordVisible = !isPasswordVisible),
        ) : null,
        // ignore: deprecated_member_use
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}
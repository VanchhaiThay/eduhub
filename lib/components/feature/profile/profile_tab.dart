import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/api_service.dart';
import 'widgets/profile_image_picker.dart';
import 'widgets/profile_header.dart';
import 'widgets/preferences_section.dart';
import 'widgets/about_us_section.dart';
import 'widgets/logout_button.dart';
import 'account_details_page.dart';

class ProfileTab extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;
  final String selectedLanguage;
  final Function(String) onLanguageChanged;

  const ProfileTab({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String? _profileImageUrl;
  bool _isUploading = false;
  final auth.User? _currentUser = auth.FirebaseAuth.instance.currentUser;
  late String _firstName;
  late String _lastName;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _profileImageUrl = _currentUser?.photoURL;
    _firstName = widget.firstName ?? '';
    _lastName = widget.lastName ?? '';
  }

  void _showEditNameDialog(
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: title,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  onSave(controller.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editFirstName() {
    _showEditNameDialog('Edit First Name', _firstName, (newValue) async {
      setState(() {
        _firstName = newValue;
      });

      // Save to both PostgreSQL (primary) and Firebase (secondary)
      try {
        // Update PostgreSQL via API (primary storage)
        await _apiService.updateUser(
          firebaseUid: _currentUser?.uid ?? '',
          firstName: newValue,
        );

        // Update Firebase Firestore (secondary storage)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser?.uid)
            .update({'firstName': newValue});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('First name updated successfully')),
        );
      } catch (e) {
        // Handle error - could show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating first name: $e')),
        );
      }
    });
  }

  void _editLastName() {
    _showEditNameDialog('Edit Last Name', _lastName, (newValue) async {
      setState(() {
        _lastName = newValue;
      });

      // Save to both PostgreSQL (primary) and Firebase (secondary)
      try {
        // Update PostgreSQL via API (primary storage)
        await _apiService.updateUser(
          firebaseUid: _currentUser?.uid ?? '',
          lastName: newValue,
        );

        // Update Firebase Firestore (secondary storage)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser?.uid)
            .update({'lastName': newValue});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Last name updated successfully')),
        );
      } catch (e) {
        // Handle error - could show a snackbar
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating last name: $e')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Check if user is logged in
    if (_currentUser == null) {
      // Show all profile components with Login/Sign Up options when logged out
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header with Login/Sign Up prompt
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [const Color(0xFF38A39D), const Color(0xFF2C8B85)],
                  ),
                ),
                child: Column(
                  children: [
                    // const SizedBox(height: 40),
                    // Profile Avatar placeholder
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 50,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    // const SizedBox(height: 20),
                    Text(
                      'Guest User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to access your profile',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Login and Sign Up buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF38A39D),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text('Login'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(color: Colors.white),
                            ),
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                    // const SizedBox(height: 30),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              // const SizedBox(height: 24),
              // const SizedBox(height: 32),
              // Preferences Section (always accessible)
              PreferencesSection(
                selectedLanguage: widget.selectedLanguage,
                onLanguageChanged: widget.onLanguageChanged,
                isDark: isDark,
              ),
              const SizedBox(height: 25),
              // About Us Section (always accessible)
              AboutUsSection(
                selectedLanguage: widget.selectedLanguage,
                isDark: isDark,
              ),
              const SizedBox(height: 40),
              // Login Button instead of Logout
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38A39D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Login / Sign Up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    }

    // Show profile when logged in
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ProfileHeader(
              firstName: _firstName,
              lastName: _lastName,
              email: widget.email,
              onEditProfile: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountDetailsPage(
                      firstName: _firstName,
                      lastName: _lastName,
                      role: widget.role,
                      email: widget.email,
                      selectedLanguage: widget.selectedLanguage,
                      onEditFirstName: _editFirstName,
                      onEditLastName: _editLastName,
                    ),
                  ),
                );
              },
              imagePicker: ProfileImagePicker(
                initialImageUrl: _profileImageUrl,
                firstName: _firstName,
                lastName: _lastName,
                onImageUrlChanged: (url) {
                  if (mounted) setState(() => _profileImageUrl = url);
                },
                onUploadStarted: () {
                  if (mounted) setState(() => _isUploading = true);
                },
                onUploadFinished: () {
                  if (mounted) setState(() => _isUploading = false);
                },
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 32),
            PreferencesSection(
              selectedLanguage: widget.selectedLanguage,
              onLanguageChanged: widget.onLanguageChanged,
              isDark: isDark,
            ),
            const SizedBox(height: 25),
            AboutUsSection(
              selectedLanguage: widget.selectedLanguage,
              isDark: isDark,
            ),
            const SizedBox(height: 40),
            LogoutButton(pageContext: context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/api_service.dart';
import 'widgets/profile_image_picker.dart';
import 'widgets/profile_header.dart';
import 'widgets/account_details_section.dart';
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
      // Show empty state when logged out
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: 80,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              Text(
                'No user logged in',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please sign in to view your profile',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38A39D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    // Show profile when logged in
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              firstName: _firstName,
              lastName: _lastName,
              imagePicker: ProfileImagePicker(
                initialImageUrl: _profileImageUrl,
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
            const SizedBox(height: 90),
            AccountDetailsSection(
              firstName: _firstName,
              lastName: _lastName,
              role: widget.role,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
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
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade100,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF38A39D).withOpacity(0.12)
                            : const Color(0xFF38A39D).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 22,
                        color: const Color(0xFF38A39D),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Profile Information',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1A1A1A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'View and edit your profile information',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
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

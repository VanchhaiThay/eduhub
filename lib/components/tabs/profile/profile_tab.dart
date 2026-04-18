import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../../utils/localization.dart';
import '../../../utils/user_data.dart';
import '../../../utils/theme_manager.dart';
import 'widgets/profile_image_picker.dart';
import 'widgets/profile_header.dart';
import 'widgets/account_info_section.dart';
import 'widgets/preferences_section.dart';
import 'widgets/logout_button.dart';

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

  @override
  void initState() {
    super.initState();
    _profileImageUrl = _currentUser?.photoURL;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              firstName: widget.firstName ?? '',
              lastName: widget.lastName ?? '',
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
            const SizedBox(height: 70),
            Text(
              "${widget.firstName ?? ''} ${widget.lastName ?? ''}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.role?.toUpperCase() ?? "MEMBER",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.tealAccent : Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 30),
            AccountInfoSection(
              selectedLanguage: widget.selectedLanguage,
              email: widget.email,
              firstName: widget.firstName,
              lastName: widget.lastName,
            ),
            const SizedBox(height: 25),
            PreferencesSection(
              selectedLanguage: widget.selectedLanguage,
              onLanguageChanged: widget.onLanguageChanged,
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

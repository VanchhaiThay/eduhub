import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eduhub/auth/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/user_data.dart';
import '../../utils/localization.dart';
import '../../utils/theme_manager.dart';

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

  // Use the prefixed auth.User to avoid conflict with Supabase's User class
  final auth.User? _currentUser = auth.FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    // Load existing photo from Firebase
    _profileImageUrl = _currentUser?.photoURL;
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image == null) return;

    // Check connectivity first
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No internet connection. Please check your network."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isUploading = true);

    const maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final file = File(image.path);
        final String userId = _currentUser?.uid ?? 'anon';
        final String fileName =
            '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await Supabase.instance.client.storage
            .from('eduhub_user_profile')
            .upload(
              fileName,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        final String publicUrl = Supabase.instance.client.storage
            .from('eduhub_user_profile')
            .getPublicUrl(fileName);

        await _currentUser?.updatePhotoURL(publicUrl);

        setState(() {
          _profileImageUrl = publicUrl;
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Profile image updated successfully! (Attempt $attempt/$maxRetries)",
              ),
              backgroundColor: Colors.teal,
            ),
          );
        }
        return;
      } catch (e) {
        debugPrint("Upload attempt $attempt/$maxRetries failed: $e");
        if (attempt < maxRetries) {
          final delay = Duration(seconds: attempt * 2); // 2s, 4s backoff
          await Future.delayed(delay);
        }
      }
    }

    setState(() => _isUploading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Upload failed after 3 retries. Check internet and try again.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    String initials =
        "${widget.firstName?.isNotEmpty == true ? widget.firstName![0] : ''}${widget.lastName?.isNotEmpty == true ? widget.lastName![0] : ''}"
            .toUpperCase();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF232526), const Color(0xFF414345)]
                          : [const Color(0xFF1E3C72), const Color(0xFF2A5298)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(40),
                    ),
                  ),
                ),
                Positioned(
                  top: 130,
                  child: GestureDetector(
                    onTap: _isUploading ? null : _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 10,
                            color: Colors.black12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: isDark
                                ? Colors.grey[800]
                                : Colors.blue.shade50,
                            backgroundImage: _profileImageUrl != null
                                ? NetworkImage(_profileImageUrl!)
                                : null,
                            child: _profileImageUrl == null
                                ? Text(
                                    initials,
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: isDark
                                          ? Colors.tealAccent
                                          : const Color(0xFF1E3C72),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                : null,
                          ),
                          if (_isUploading)
                            const CircularProgressIndicator(
                              color: Colors.tealAccent,
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.tealAccent,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
            _buildSectionTitle(
              Localization.text(widget.selectedLanguage, 'accountDetails'),
            ),
            _buildSettingsCard(context, [
              _infoRow(
                context,
                Icons.email_outlined,
                Localization.text(widget.selectedLanguage, 'email'),
                widget.email,
              ),
              _infoRow(
                context,
                Icons.person_outline,
                Localization.text(widget.selectedLanguage, 'firstName'),
                widget.firstName,
              ),
              _infoRow(
                context,
                Icons.badge_outlined,
                Localization.text(widget.selectedLanguage, 'lastName'),
                widget.lastName,
              ),
            ]),
            const SizedBox(height: 25),
            _buildSectionTitle(
              Localization.text(widget.selectedLanguage, 'preferences'),
            ),
            _buildSettingsCard(context, [
              _buildLanguageDropdown(context),
              const Divider(height: 1),
              SwitchListTile.adaptive(
                secondary: Icon(
                  Icons.dark_mode_outlined,
                  color: Colors.blueGrey.shade400,
                ),
                title: Text(
                  Localization.text(widget.selectedLanguage, 'Dark Mode'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: isDark,
                activeColor: Colors.tealAccent,
                onChanged: (bool value) => ThemeManager.toggleTheme(value),
              ),
            ]),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TextButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: Colors.red.withOpacity(0.05),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
        ),
      ),
    ),
  );

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: children),
      );

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    child: Row(
      children: [
        Icon(icon, size: 22, color: Colors.blueGrey.shade400),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            Text(
              value ?? "-",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildLanguageDropdown(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(
      children: [
        Icon(Icons.translate, size: 22, color: Colors.blueGrey.shade400),
        const SizedBox(width: 15),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: widget.selectedLanguage,
              isExpanded: true,
              items: ["Khmer", "English", "Chinese", "Vietnamese"]
                  .map(
                    (lang) => DropdownMenuItem(value: lang, child: Text(lang)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.onLanguageChanged(value);
                  UserData.saveLanguage(value);
                }
              },
            ),
          ),
        ),
      ],
    ),
  );

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await auth.FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

import 'package:eduhub/auth/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/user_data.dart';
import '../../utils/localization.dart';
import '../../utils/theme_manager.dart'; // Import your manager

class ProfileTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Detect if the app is currently in Dark Mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    String initials = "${firstName?.isNotEmpty == true ? firstName![0] : ''}${lastName?.isNotEmpty == true ? lastName![0] : ''}".toUpperCase();

    return Scaffold(
      // The background will now automatically adapt based on your Theme data
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Modern Header ---
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
                        ? [const Color(0xFF232526), const Color(0xFF414345)] // Darker gradient
                        : [const Color(0xFF1E3C72), const Color(0xFF2A5298)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                ),
                Positioned(
                  top: 130,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      shape: BoxShape.circle,
                      boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 2)],
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.blue.shade50,
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 32, 
                          color: isDark ? Colors.tealAccent : const Color(0xFF1E3C72), 
                          fontWeight: FontWeight.w800
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70),

            Text(
              "${firstName ?? ''} ${lastName ?? ''}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Text(
              role?.toUpperCase() ?? "MEMBER",
              style: TextStyle(fontSize: 14, color: isDark ? Colors.tealAccent : Colors.blue.shade700, fontWeight: FontWeight.w600, letterSpacing: 1.2),
            ),

            const SizedBox(height: 30),

            // --- Details Card ---
            _buildSectionTitle(Localization.text(selectedLanguage, 'accountDetails')),
            _buildSettingsCard(context, [
              _infoRow(context, Icons.email_outlined, Localization.text(selectedLanguage, 'email'), email),
              _infoRow(context, Icons.person_outline, Localization.text(selectedLanguage, 'firstName'), firstName),
              _infoRow(context, Icons.badge_outlined, Localization.text(selectedLanguage, 'lastName'), lastName),
            ]),

            const SizedBox(height: 25),

            // --- Preferences Card ---
            _buildSectionTitle(Localization.text(selectedLanguage, 'preferences')),
            _buildSettingsCard(context, [
              _buildLanguageDropdown(context),
              const Divider(height: 1),
              // --- DARK MODE TOGGLE ---
              SwitchListTile.adaptive(
                secondary: Icon(Icons.dark_mode_outlined, color: Colors.blueGrey.shade400),
                title: const Text("Dark Mode", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                value: isDark,
                // ignore: deprecated_member_use
                activeColor: Colors.tealAccent,
                onChanged: (bool value) {
                  ThemeManager.toggleTheme(value);
                },
              ),
            ]),

            const SizedBox(height: 40),

            // --- Logout Button ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: TextButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  // ignore: deprecated_member_use
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.red.withOpacity(0.2))),
                  // ignore: deprecated_member_use
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

  // --- UI Helper Methods (Modified to support context/theme) ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blueGrey.shade400),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              Text(value ?? "-", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.translate, size: 22, color: Colors.blueGrey.shade400),
          const SizedBox(width: 15),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedLanguage,
                isExpanded: true,
                dropdownColor: Theme.of(context).cardColor,
                items: ["Khmer", "English", "Chinese", "Vietnamese"]
                    .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onLanguageChanged(value);
                    UserData.saveLanguage(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
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
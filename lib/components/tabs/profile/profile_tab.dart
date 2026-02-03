import 'package:eduhub/auth/signin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/user_data.dart';
import '../../utils/localization.dart';

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
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with Gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Text(
                    "${firstName?.substring(0, 1) ?? ''}${lastName?.substring(0, 1) ?? ''}",
                    style: const TextStyle(fontSize: 36, color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  "$firstName $lastName",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "$role",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Info Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              shadowColor: Colors.grey.shade300,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Localization.text(selectedLanguage, 'email'), email),
                    const Divider(),
                    _infoRow(Localization.text(selectedLanguage, 'firstName'), firstName),
                    const Divider(),
                    _infoRow(Localization.text(selectedLanguage, 'lastName'), lastName),
                    const Divider(),
                    _infoRow(Localization.text(selectedLanguage, 'role'), role),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Language Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localization.text(selectedLanguage, 'selectLanguage'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: selectedLanguage,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: "Khmer", child: Text("Khmer")),
                      DropdownMenuItem(value: "English", child: Text("English")),
                      DropdownMenuItem(value: "Chinese", child: Text("Chinese")),
                      DropdownMenuItem(value: "Vietnamese", child: Text("Vietnamese")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onLanguageChanged(value);
                        UserData.saveLanguage(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Helper widget for info rows
  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

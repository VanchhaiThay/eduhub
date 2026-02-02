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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage("assets/images/profile_placeholder.png"),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(height: 20),
          Text(
            "$firstName $lastName",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "$role",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Info Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 3,
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

          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              Localization.text(selectedLanguage, 'selectLanguage'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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

          const SizedBox(height: 30),
          // Logout Button
          SizedBox(
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
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
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
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

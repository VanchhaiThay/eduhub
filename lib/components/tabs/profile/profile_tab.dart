import 'package:flutter/material.dart';
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
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${Localization.text(selectedLanguage, 'firstName')}: $firstName",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("${Localization.text(selectedLanguage, 'lastName')}: $lastName",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("${Localization.text(selectedLanguage, 'email')}: $email",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("${Localization.text(selectedLanguage, 'role')}: $role",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Text(Localization.text(selectedLanguage, 'selectLanguage'),
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedLanguage,
              items: const [
                DropdownMenuItem(value: "Khmer", child: Text("Khmer")),
                DropdownMenuItem(value: "English", child: Text("English")),
                DropdownMenuItem(value: "Chinese", child: Text("Chinese")),
                DropdownMenuItem(value: "Vietnamese", child: Text("Vietnamese")),
              ],
              onChanged: (value) {
                if (value != null) onLanguageChanged(value);
                UserData.saveLanguage(value!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
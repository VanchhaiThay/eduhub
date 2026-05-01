import 'package:flutter/material.dart';
import 'widgets/account_details_section.dart';
import 'widgets/account_info_section.dart';

class AccountDetailsPage extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String? role;
  final String? email;
  final String selectedLanguage;
  final VoidCallback? onEditFirstName;
  final VoidCallback? onEditLastName;

  const AccountDetailsPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.email,
    required this.selectedLanguage,
    this.onEditFirstName,
    this.onEditLastName,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account Details',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            AccountDetailsSection(
              firstName: firstName,
              lastName: lastName,
              role: role,
              isDark: isDark,
            ),
            const SizedBox(height: 32),
            AccountInfoSection(
              selectedLanguage: selectedLanguage,
              email: email,
              firstName: firstName,
              lastName: lastName,
              onEditFirstName: onEditFirstName,
              onEditLastName: onEditLastName,
            ),
          ],
        ),
      ),
    );
  }
}

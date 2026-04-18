import 'package:flutter/material.dart';
import '../../../../utils/localization.dart';

class AccountInfoSection extends StatelessWidget {
  final String selectedLanguage;
  final String? email;
  final String? firstName;
  final String? lastName;

  const AccountInfoSection({
    super.key,
    required this.selectedLanguage,
    this.email,
    this.firstName,
    this.lastName,
  });

  Widget _buildSectionTitle(String title, {required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blueGrey.shade400),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                Text(
                  value ?? "-",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSectionTitle(
          Localization.text(selectedLanguage, 'accountDetails'),
          context: context,
        ),
        _buildSettingsCard(context, [
          _infoRow(
            context,
            Icons.email_outlined,
            Localization.text(selectedLanguage, 'email'),
            email,
          ),
          _infoRow(
            context,
            Icons.person_outline,
            Localization.text(selectedLanguage, 'firstName'),
            firstName,
          ),
          _infoRow(
            context,
            Icons.badge_outlined,
            Localization.text(selectedLanguage, 'lastName'),
            lastName,
          ),
        ]),
      ],
    );
  }
}

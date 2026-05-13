import 'package:flutter/material.dart';
import '../../../../utils/localization.dart';

class AccountInfoSection extends StatelessWidget {
  final String selectedLanguage;
  final String? email;
  final String? firstName;
  final String? lastName;
  final VoidCallback? onEditFirstName;
  final VoidCallback? onEditLastName;

  const AccountInfoSection({
    super.key,
    required this.selectedLanguage,
    this.email,
    this.firstName,
    this.lastName,
    this.onEditFirstName,
    this.onEditLastName,
  });

  Widget _buildSectionTitle(String title, {required BuildContext context}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value, {
    VoidCallback? onEdit,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: onEdit != null
              ? (isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
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
              child: Icon(icon, size: 22, color: const Color(0xFF38A39D)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value ?? "-",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
              ),
          ],
        ),
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
            onEdit: onEditFirstName,
          ),
          _infoRow(
            context,
            Icons.badge_outlined,
            Localization.text(selectedLanguage, 'lastName'),
            lastName,
            onEdit: onEditLastName,
          ),
        ]),
      ],
    );
  }
}

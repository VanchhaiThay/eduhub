import 'package:flutter/material.dart';

class AccountDetailsSection extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String? role;
  final bool isDark;

  const AccountDetailsSection({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$firstName $lastName",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF38A39D).withOpacity(0.15)
                : const Color(0xFF38A39D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            role?.toUpperCase() ?? "MEMBER",
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF38A39D),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

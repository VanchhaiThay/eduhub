import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String firstName;
  final String lastName;
  final Widget imagePicker; // Pass the ProfileImagePicker
  final bool isDark;

  const ProfileHeader({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.imagePicker,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1a1d21), const Color(0xFF2d3136)]
                  : [const Color(0xFFf8f9fa), const Color(0xFFe9ecef)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
          ),
        ),
        Positioned(top: 120, child: imagePicker),
      ],
    );
  }
}

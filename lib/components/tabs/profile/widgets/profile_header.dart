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
    String initials =
        "${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}"
            .toUpperCase();

    return Stack(
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
        Positioned(top: 130, child: imagePicker),
      ],
    );
  }
}

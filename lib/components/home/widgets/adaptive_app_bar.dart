import 'package:flutter/material.dart';
import 'custom_app_bar.dart';

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int selectedIndex;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;
  final String? photoUrl;
  final int notificationCount;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final bool isDark;

  const AdaptiveAppBar({
    super.key,
    required this.selectedIndex,
    this.firstName,
    this.lastName,
    this.email,
    this.role,
    this.photoUrl,
    this.notificationCount = 0,
    required this.onProfileTap,
    required this.onNotificationTap,
    required this.isDark,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 4) {
      // Profile page AppBar
      return AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF38A39D),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/customer-service');
            },
            icon: const Icon(
              Icons.headphones_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      );
    } else {
      // Custom AppBar for other pages
      return CustomAppBar(
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        photoUrl: photoUrl,
        notificationCount: notificationCount,
        onProfileTap: onProfileTap,
        onNotificationTap: onNotificationTap,
        isDark: isDark,
        hideNotifications: selectedIndex == 4,
      );
    }
  }
}

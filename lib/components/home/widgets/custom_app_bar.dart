import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? role;
  final String? photoUrl;
  final int notificationCount;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;
  final bool isDark;

  const CustomAppBar({
    super.key,
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1F1F1F), const Color(0xFF2C2C2C)]
              : [const Color(0xFF38A39D), const Color(0xFF2B827D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Container(),
        title: Row(
          children: [
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl!)
                      : null,
                  child: photoUrl == null
                      ? Text(
                          "${firstName?[0] ?? ""}${lastName?[0] ?? ""}",
                          style: const TextStyle(
                            color: Color(0xFF38A39D),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${firstName ?? ""} ${lastName ?? ""}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white30, width: 0.5),
                    ),
                    child: Text(
                      role?.toUpperCase() ?? "",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: onNotificationTap,
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 10,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1F1F1F)
                              : const Color(0xFF38A39D),
                          width: 1.5,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

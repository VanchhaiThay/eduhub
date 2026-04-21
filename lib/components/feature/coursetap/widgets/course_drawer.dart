import 'package:flutter/material.dart';
import 'package:eduhub/components/core/app_color.dart';

class CourseDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Color backgroundColor;

  const CourseDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = AppColors.getPrimaryColor(isDark);

    return Drawer(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          _drawerItem(context, Icons.book_rounded, "Courses", 0, primaryColor),
          _drawerItem(context, Icons.local_library_rounded, "Library", 1, primaryColor),
          const Spacer(),
          const Divider(indent: 20, endIndent: 20),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(
              "Logout",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
            onTap: () {},
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, int index, Color primaryColor) {
    bool selected = selectedIndex == index;
    return ListTile(
      selected: selected,
      selectedTileColor: primaryColor.withOpacity(0.1),
      leading: Icon(icon, color: selected ? primaryColor : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? primaryColor : null,
        ),
      ),
      onTap: () {
        onItemSelected(index);
        Navigator.pop(context);
      },
    );
  }
}
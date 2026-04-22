// --- CONTENT 2: LIBRARY VIEW ---
import 'package:flutter/material.dart';
import 'package:eduhub/components/core/app_color.dart';

Widget _buildLibraryContent(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  final Color primaryColor = AppColors.getPrimaryColor(isDark);
  final Color surfaceColor = AppColors.getSurfaceColor(isDark);
  final Color textColor = AppColors.getTextColor(isDark);
  final Color subTextColor = AppColors.getSubTextColor(isDark);

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: 8,
    itemBuilder: (context, index) {
      return Card(
        elevation: 0,
        color: surfaceColor,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.picture_as_pdf, color: Colors.red),
          ),
          title: Text(
            "Reference Material ${index + 1}",
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
          ),
          subtitle: Text("E-Book • 12.4 MB", style: TextStyle(color: subTextColor)),
          trailing: Icon(Icons.download_for_offline, color: primaryColor),
          onTap: () {
            // Open PDF logic
          },
        ),
      );
    },
  );
}
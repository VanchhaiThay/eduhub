import 'package:flutter/material.dart';
import 'package:eduhub/components/core/app_color.dart';

class CourseLibrary extends StatelessWidget {
  const CourseLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = AppColors.getPrimaryColor(isDark);
    final Color surfaceColor = AppColors.getSurfaceColor(isDark);

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
            ),
            title: Text(
              "Reference Material ${index + 1}",
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              "Grade 12 • Chemistry • 5.2 MB",
              style: TextStyle(fontSize: 12),
            ),
            trailing: IconButton(
              icon: Icon(Icons.download_for_offline_rounded, color: primaryColor),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}
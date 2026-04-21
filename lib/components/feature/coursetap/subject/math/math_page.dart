import 'package:flutter/material.dart';
import 'package:eduhub/components/core/app_color.dart';
// --- Grade Page Imports ---
import 'package:eduhub/components/feature/coursetap/subject/math/grade/grade1.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade/grade10.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade/grade11.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade/grade12.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade/grade2.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade/grade3.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade/grade4.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade/grade5.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade/grade6.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade/grade7.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade/grade8.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade/grade9.dart';

class MathPage extends StatelessWidget {
  const MathPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = AppColors.getPrimaryColor(isDark);
    final Color backgroundColor = AppColors.getBackgroundColor(isDark);

    final List<Map<String, dynamic>> gradeList = [
      {'title': 'Grade 1', 'page': const Grade1Page()},
      {'title': 'Grade 2', 'page': const Grade2Page()},
      {'title': 'Grade 3', 'page': const Grade3Page()},
      {'title': 'Grade 4', 'page': const Grade4Page()},
      {'title': 'Grade 5', 'page': const Grade5Page()},
      {'title': 'Grade 6', 'page': const Grade6Page()},
      {'title': 'Grade 7', 'page': const Grade7Page()},
      {'title': 'Grade 8', 'page': const Grade8Page()},
      {'title': 'Grade 9', 'page': const Grade9Page()},
      {'title': 'Grade 10', 'page': const Grade10Page()},
      {'title': 'Grade 11', 'page': const Grade11Page()},
      {'title': 'Grade 12', 'page': const Grade12Page()},
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calculate_rounded, color: primaryColor, size: 28),
            const SizedBox(width: 10),
            const Text(
              "Mathematics",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                fontSize: 22,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.getTextColor(isDark),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(isDark ? 0.15 : 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.school_rounded, color: primaryColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  "Select your grade level to begin learning",
                  style: TextStyle(
                    color: AppColors.getSubTextColor(isDark),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              physics: const BouncingScrollPhysics(),
              itemCount: gradeList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                final item = gradeList[index];
                return _buildGradeCard(context, item, isDark, primaryColor);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, Map<String, dynamic> item, bool isDark, Color primaryColor) {
    final String title = item['title'];
    final Color gradeColor = GradeColors.getColor(title);
    final IconData gradeIcon = GradeColors.getIcon(title);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => item['page']),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
            ? gradeColor.withOpacity(0.12)
            : AppColors.getSurfaceColor(isDark),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: gradeColor.withOpacity(isDark ? 0.3 : 0.15),
            width: 1.5,
          ),
          boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradeColor.withOpacity(0.15),
                    gradeColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: gradeColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                gradeIcon,
                size: 34,
                color: gradeColor,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.getTextColor(isDark),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: gradeColor.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Lessons",
                style: TextStyle(
                  fontSize: 11,
                  color: gradeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
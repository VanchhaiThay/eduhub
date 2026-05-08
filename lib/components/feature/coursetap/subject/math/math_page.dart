import 'package:flutter/material.dart';
import 'package:eduhub/components/core/app_color.dart';
import 'package:eduhub/constants/app/asset_app.dart';
// --- Grade Page Imports ---
import 'package:eduhub/components/feature/coursetap/subject/math/grade1.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade10.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade11.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade12.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade2.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade3.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade4.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade5.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade6.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade7.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade8.dart';
import 'package:eduhub/components/feature/coursetap/subject/math/grade9.dart';

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
        title: const Text(
          "Mathematics",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.getTextColor(isDark),
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        AppAssets.star,
                        width: 16,
                        height: 16,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "PERSONALIZED JOURNEY",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Select your grade level to begin learning",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Every mathematical genius started with a single step. Choose your current level and we'll tailor a curriculum just for your goals.",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.getSubTextColor(isDark),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...gradeList.map(
            (item) => _buildGradeCard(context, item, isDark, primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(
    BuildContext context,
    Map<String, dynamic> item,
    bool isDark,
    Color primaryColor,
  ) {
    final String title = item['title'];
    final Color gradeColor = GradeColors.getColor(title);
    final IconData gradeIcon = GradeColors.getIcon(title);
    final String description = GradeColors.getDescription(title);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => item['page']),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? gradeColor.withOpacity(0.12)
              : AppColors.getSurfaceColor(isDark),
          borderRadius: BorderRadius.circular(16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
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
              child: Icon(gradeIcon, size: 28, color: gradeColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.getTextColor(isDark),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getSubTextColor(isDark),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: gradeColor.withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Lessons",
                      style: TextStyle(
                        fontSize: 10,
                        color: gradeColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.getSubTextColor(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

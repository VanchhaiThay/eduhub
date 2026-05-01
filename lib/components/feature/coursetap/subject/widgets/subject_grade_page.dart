import 'package:eduhub/components/app/asset_app.dart';
import 'package:eduhub/components/core/app_color.dart';
import 'package:flutter/material.dart';

class SubjectGradePage extends StatelessWidget {
  final String subjectTitle;
  final String heroTitle;
  final String heroDescription;
  final int startGrade;
  final int endGrade;
  final Map<String, Widget> gradePages;

  const SubjectGradePage({
    super.key,
    required this.subjectTitle,
    required this.heroTitle,
    required this.heroDescription,
    this.startGrade = 1,
    this.endGrade = 12,
    this.gradePages = const {},
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = AppColors.getPrimaryColor(isDark);
    final Color backgroundColor = AppColors.getBackgroundColor(isDark);

    final List<String> gradeTitles = List.generate(
      (endGrade - startGrade) + 1,
      (i) => 'Grade ${startGrade + i}',
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          subjectTitle,
          style: const TextStyle(
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
                heroTitle,
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
                heroDescription,
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
          ...gradeTitles.map(
            (title) => _buildGradeCard(context, title, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, String title, bool isDark) {
    final Color gradeColor = GradeColors.getColor(title);
    final IconData gradeIcon = GradeColors.getIcon(title);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              gradePages[title] ??
              SubjectGradeDetailPage(subjectTitle: subjectTitle, gradeTitle: title),
        ),
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
                    '$subjectTitle lessons',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.getSubTextColor(isDark),
                      fontWeight: FontWeight.w500,
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

class SubjectGradeDetailPage extends StatelessWidget {
  final String subjectTitle;
  final String gradeTitle;

  const SubjectGradeDetailPage({
    super.key,
    required this.subjectTitle,
    required this.gradeTitle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(isDark),
      appBar: AppBar(
        title: Text('$subjectTitle - $gradeTitle'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.getTextColor(isDark),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '$subjectTitle content for $gradeTitle is ready to be added.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getTextColor(isDark),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

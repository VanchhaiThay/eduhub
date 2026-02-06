import 'package:flutter/material.dart';
// --- Grade Page Imports ---
import 'package:eduhub/components/tabs/coursetap/subject/math/grade/grade1.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math/grade/grade10.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math/grade/grade11.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math/grade/grade12.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math/grade/grade2.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math/grade/grade3.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math/grade/grade4.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math/grade/grade5.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math/grade/grade6.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math/grade/grade7.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math/grade/grade8.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math/grade/grade9.dart';

class MathPage extends StatelessWidget {
  const MathPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> gradeList = [
      {'title': 'Grade 1', 'color': Colors.redAccent, 'icon': Icons.filter_1, 'page': const Grade1Page()},
      {'title': 'Grade 2', 'color': Colors.orangeAccent, 'icon': Icons.filter_2, 'page': const Grade2Page()},
      {'title': 'Grade 3', 'color': Colors.amber, 'icon': Icons.filter_3, 'page': const Grade3Page()},
      {'title': 'Grade 4', 'color': Colors.greenAccent, 'icon': Icons.filter_4, 'page': const Grade4Page()},
      {'title': 'Grade 5', 'color': Colors.teal, 'icon': Icons.filter_5, 'page': const Grade5Page()},
      {'title': 'Grade 6', 'color': Colors.blueAccent, 'icon': Icons.filter_6, 'page': const Grade6Page()},
      {'title': 'Grade 7', 'color': Colors.indigoAccent, 'icon': Icons.filter_7, 'page': const Grade7Page()},
      {'title': 'Grade 8', 'color': Colors.purpleAccent, 'icon': Icons.filter_8, 'page': const Grade8Page()},
      {'title': 'Grade 9', 'color': Colors.pinkAccent, 'icon': Icons.filter_9, 'page': const Grade9Page()},
      {'title': 'Grade 10', 'color': Colors.deepOrange, 'icon': Icons.school_rounded, 'page': const Grade10Page()},
      {'title': 'Grade 11', 'color': Colors.cyan, 'icon': Icons.functions_rounded, 'page': const Grade11Page()},
      {'title': 'Grade 12', 'color': Colors.blueGrey, 'icon': Icons.calculate_rounded, 'page': const Grade12Page()},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Mathematics Portal",
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.teal.shade700,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        itemCount: gradeList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 18,
          mainAxisSpacing: 18,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final item = gradeList[index];
          return _buildGradeCard(context, item, isDark);
        },
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, Map<String, dynamic> item, bool isDark) {
    final Color gradeColor = item['color'];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => item['page']),
      ),
      child: Container(
        decoration: BoxDecoration(
          // Soft glass effect: darker in dark mode, lighter in light mode
          color: isDark ? gradeColor.withOpacity(0.15) : gradeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: gradeColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Container for a more professional "App" feel
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.white54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'],
                size: 32,
                color: gradeColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              item['title'],
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Lessons & Tasks",
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
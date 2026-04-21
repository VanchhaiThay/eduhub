import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryTeal = Colors.teal;
  static const Color primaryTealDark = Colors.teal;
  static const Color primaryTealLight = Colors.teal;

  static Color getPrimaryColor(bool isDark) {
    return isDark ? Colors.teal.shade300 : Colors.teal.shade700;
  }

  static Color getBackgroundColor(bool isDark) {
    return isDark ? const Color(0xFF121212) : Colors.grey.shade50;
  }

  static Color getSurfaceColor(bool isDark) {
    return isDark ? const Color(0xFF1E1E1E) : Colors.white;
  }

  static Color getTextColor(bool isDark) {
    return isDark ? Colors.white : Colors.grey.shade800;
  }

  static Color getSubTextColor(bool isDark) {
    return isDark ? Colors.white70 : Colors.grey.shade600;
  }
}

class GradeColors {
  static const List<Map<String, dynamic>> grades = [
    {'title': 'Grade 1', 'color': Colors.redAccent, 'icon': Icons.filter_1},
    {'title': 'Grade 2', 'color': Colors.orangeAccent, 'icon': Icons.filter_2},
    {'title': 'Grade 3', 'color': Colors.amber, 'icon': Icons.filter_3},
    {'title': 'Grade 4', 'color': Colors.greenAccent, 'icon': Icons.filter_4},
    {'title': 'Grade 5', 'color': Colors.teal, 'icon': Icons.filter_5},
    {'title': 'Grade 6', 'color': Colors.blueAccent, 'icon': Icons.filter_6},
    {'title': 'Grade 7', 'color': Colors.indigoAccent, 'icon': Icons.filter_7},
    {'title': 'Grade 8', 'color': Colors.purpleAccent, 'icon': Icons.filter_8},
    {'title': 'Grade 9', 'color': Colors.pinkAccent, 'icon': Icons.filter_9},
    {'title': 'Grade 10', 'color': Colors.deepOrange, 'icon': Icons.school_rounded},
    {'title': 'Grade 11', 'color': Colors.cyan, 'icon': Icons.functions_rounded},
    {'title': 'Grade 12', 'color': Colors.blueGrey, 'icon': Icons.calculate_rounded},
  ];

  static Color getColor(String gradeTitle) {
    final grade = grades.firstWhere(
      (g) => g['title'] == gradeTitle,
      orElse: () => {'color': Colors.grey},
    );
    return grade['color'];
  }

  static IconData getIcon(String gradeTitle) {
    final grade = grades.firstWhere(
      (g) => g['title'] == gradeTitle,
      orElse: () => {'icon': Icons.school},
    );
    return grade['icon'];
  }
}
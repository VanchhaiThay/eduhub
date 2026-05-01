import 'package:flutter/material.dart';
import 'package:eduhub/components/app/asset_app.dart';

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

class SubjectColors {
  static const List<Map<String, dynamic>> subjects = [
    {
      "nameKey": "khmer",
      "icon": AppAssets.khmerIcon,
      "color": Colors.deepPurple,
    },
    {"nameKey": "math", "icon": AppAssets.mathIcon, "color": Colors.blue},
    {
      "nameKey": "history",
      "icon": AppAssets.historyIcon,
      "color": Colors.brown,
    },
    {
      "nameKey": "language",
      "icon": AppAssets.languageIcon,
      "color": Colors.orange,
    },
    {
      "nameKey": "geography",
      "icon": AppAssets.geographyIcon,
      "color": Colors.cyan,
    },
    {
      "nameKey": "physics",
      "icon": AppAssets.physicsIcon,
      "color": Colors.indigo,
    },
    {
      "nameKey": "chemistry",
      "icon": AppAssets.chemistryIcon,
      "color": Colors.teal,
    },
    {
      "nameKey": "biology",
      "icon": AppAssets.biologyIcon,
      "color": Colors.lightGreen,
    },
    {"nameKey": "tech", "icon": AppAssets.techIcon, "color": Colors.blueGrey},
  ];

  static Color getColor(String nameKey) {
    final subject = subjects.firstWhere(
      (s) => s['nameKey'] == nameKey,
      orElse: () => {'color': Colors.grey},
    );
    return subject['color'];
  }

  static String getIcon(String nameKey) {
    final subject = subjects.firstWhere(
      (s) => s['nameKey'] == nameKey,
      orElse: () => {'icon': AppAssets.mathIcon},
    );
    return subject['icon'];
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
    {
      'title': 'Grade 10',
      'color': Colors.deepOrange,
      'icon': Icons.school_rounded,
    },
    {
      'title': 'Grade 11',
      'color': Colors.cyan,
      'icon': Icons.functions_rounded,
    },
    {
      'title': 'Grade 12',
      'color': Colors.blueGrey,
      'icon': Icons.calculate_rounded,
    },
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

  static String getDescription(String gradeTitle) {
    switch (gradeTitle) {
      case 'Grade 1':
        return 'Foundational skills';
      case 'Grade 2':
        return 'Building basics';
      case 'Grade 3':
        return 'Growing confidence';
      case 'Grade 4':
        return 'Expanding knowledge';
      case 'Grade 5':
        return 'Critical thinking';
      case 'Grade 6':
        return 'Advanced concepts';
      case 'Grade 7':
        return 'Pre-algebra prep';
      case 'Grade 8':
        return 'Algebra basics';
      case 'Grade 9':
        return 'Algebra I';
      case 'Grade 10':
        return 'Geometry';
      case 'Grade 11':
        return 'Algebra II';
      case 'Grade 12':
        return 'Pre-calculus';
      default:
        return 'Mathematics';
    }
  }
}

import 'package:eduhub/components/feature/coursetap/subject/language/language.dart';
import 'package:flutter/material.dart';
import 'package:eduhub/components/core/app_color.dart';
import '../subject/biology/biology_page.dart';
import '../subject/chemistry/chemistry_page.dart';
import '../subject/geography/geography_page.dart';
import '../subject/history/history_page.dart';
import '../subject/math/math_page.dart';
import '../subject/khmer/khmer_page.dart';
import '../subject/physics/physics_page.dart';
import '../subject/tech/tech_page.dart';

class CourseData {
  static List<Map<String, dynamic>> get subjects => SubjectColors.subjects;

  static Map<String, Widget> getSubjectRoutes() {
    return {
      "math": const MathPage(),
      "history": const HistoryPage(),
      "language": const LanguagePage(),
      "geography": const GeographyPage(),
      "physics": const PhysicsPage(),
      "chemistry": const ChemistryPage(),
      "biology": const BiologyPage(),
      "khmer": const KhmerPage(),
      "tech": const TechPage(),
    };
  }
}

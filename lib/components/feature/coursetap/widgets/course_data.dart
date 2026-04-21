import 'package:flutter/material.dart';
import 'package:eduhub/components/core/app_color.dart';
import '../subject/art/art_page.dart';
import '../subject/biology/biology_page.dart';
import '../subject/chemistry/chemistry_page.dart';
import '../subject/english/english_page.dart';
import '../subject/geography/geography_page.dart';
import '../subject/history/history_page.dart';
import '../subject/math/math_page.dart';
import '../subject/khmer/khmer_page.dart';
import '../subject/physics/physics_page.dart';
import '../subject/science/science_page.dart';
import '../subject/sports/sports_page.dart';
import '../subject/tech/tech_page.dart';

class CourseData {
  static List<Map<String, dynamic>> get subjects => SubjectColors.subjects;

  static Map<String, Widget> getSubjectRoutes() {
    return {
      "math": const MathPage(),
      "science": const SciencePage(),
      "history": const HistoryPage(),
      "english": const EnglishPage(),
      "geography": const GeographyPage(),
      "physics": const PhysicsPage(),
      "chemistry": const ChemistryPage(),
      "biology": const BiologyPage(),
      "art": const ArtPage(),
      "khmer": const KhmerPage(),
      "tech": const TechPage(),
      "sports": const SportsPage(),
    };
  }
}
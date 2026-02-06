import 'package:eduhub/components/tabs/hometap/subject/art_page.dart';
import 'package:eduhub/components/tabs/hometap/subject/biology_page.dart';
import 'package:eduhub/components/tabs/hometap/subject/chemistry_page.dart';
import 'package:eduhub/components/tabs/hometap/subject/english_page.dart';
import 'package:eduhub/components/tabs/hometap/subject/geography_page.dart';
import 'package:eduhub/components/tabs/hometap/subject/history_page.dart';
import 'package:eduhub/components/tabs/hometap/subject/math_page.dart';
import 'package:eduhub/components/tabs/hometap/subject/khmer_page.dart';
import 'package:eduhub/components/tabs/hometap/subject/physics_page.dart';
import 'package:eduhub/components/tabs/hometap/subject/science_page.dart';
import 'package:eduhub/components/tabs/hometap/subject/sports_page.dart';
import 'package:eduhub/components/tabs/hometap/subject/tech_page.dart';
import 'package:flutter/material.dart';
import '../../utils/localization.dart';

class CourseTab extends StatelessWidget {
  final String selectedLanguage;

  const CourseTab({super.key, required this.selectedLanguage});

  Map<String, Widget> _getSubjectRoutes() {
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

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> subjects = [
      {"nameKey": "math", "icon": Icons.calculate, "color": Colors.blue},
      {"nameKey": "science", "icon": Icons.science, "color": Colors.green},
      {"nameKey": "history", "icon": Icons.history_edu, "color": Colors.brown},
      {"nameKey": "english", "icon": Icons.translate, "color": Colors.orange},
      {"nameKey": "geography", "icon": Icons.public, "color": Colors.cyan},
      {"nameKey": "physics", "icon": Icons.wb_iridescent, "color": Colors.indigo},
      {"nameKey": "chemistry", "icon": Icons.biotech, "color": Colors.teal},
      {"nameKey": "biology", "icon": Icons.psychology, "color": Colors.lightGreen},
      {"nameKey": "art", "icon": Icons.palette, "color": Colors.pink},
      {"nameKey": "khmer", "icon": Icons.translate, "color": Colors.deepPurple},
      {"nameKey": "tech", "icon": Icons.computer, "color": Colors.blueGrey},
      {"nameKey": "sports", "icon": Icons.sports_basketball, "color": Colors.redAccent},
    ];

    final routes = _getSubjectRoutes();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(Localization.text(selectedLanguage, 'coursePage')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: Localization.text(selectedLanguage, 'searchsubjects'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              "Choose Subject",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade900,
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.builder(
                itemCount: subjects.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final item = subjects[index];
                  final key = item['nameKey'];

                  return GestureDetector(
                    onTap: () {
                      if (routes.containsKey(key)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => routes[key]!),
                        );
                      }
                    },
                    child: _buildSubjectCard(
                      Localization.text(selectedLanguage, key),
                      item['icon'],
                      item['color'],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(String title, IconData icon, Color color) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../utils/localization.dart';

// --- Subject Page Imports ---
import 'package:eduhub/components/tabs/coursetap/subject/art_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/biology_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/chemistry_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/english_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/geography_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/history_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math/math_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/khmer_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/physics_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/science_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/sports_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/tech_page.dart';

class CourseTab extends StatefulWidget {
  final String selectedLanguage;
  const CourseTab({super.key, required this.selectedLanguage});

  @override
  State<CourseTab> createState() => _CourseTabState();
}

class _CourseTabState extends State<CourseTab> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSubjects = [];

  final List<Map<String, dynamic>> _allSubjects = [
    {
      "nameKey": "khmer",
      "icon": Icons.language_rounded,
      "color": Colors.deepPurple
    },
    {"nameKey": "math", "icon": Icons.calculate_rounded, "color": Colors.blue},
    {
      "nameKey": "science",
      "icon": Icons.science_rounded,
      "color": Colors.green
    },
    {
      "nameKey": "history",
      "icon": Icons.history_edu_rounded,
      "color": Colors.brown
    },
    {
      "nameKey": "english",
      "icon": Icons.translate_rounded,
      "color": Colors.orange
    },
    {
      "nameKey": "geography",
      "icon": Icons.public_rounded,
      "color": Colors.cyan
    },
    {
      "nameKey": "physics",
      "icon": Icons.wb_iridescent_rounded,
      "color": Colors.indigo
    },
    {
      "nameKey": "chemistry",
      "icon": Icons.biotech_rounded,
      "color": Colors.teal
    },
    {
      "nameKey": "biology",
      "icon": Icons.psychology_rounded,
      "color": Colors.lightGreen
    },
    {"nameKey": "art", "icon": Icons.palette_rounded, "color": Colors.pink},
    {
      "nameKey": "tech",
      "icon": Icons.computer_rounded,
      "color": Colors.blueGrey
    },
    {
      "nameKey": "sports",
      "icon": Icons.sports_basketball_rounded,
      "color": Colors.redAccent
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredSubjects = _allSubjects;
  }

  // --- RESTORED ROUTE MAP ---
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

  void _runFilter(String enteredKeyword) {
    setState(() {
      if (enteredKeyword.isEmpty) {
        _filteredSubjects = _allSubjects;
      } else {
        _filteredSubjects = _allSubjects.where((subject) {
          String translatedName =
              Localization.text(widget.selectedLanguage, subject['nameKey'])
                  .toLowerCase();
          return translatedName.contains(enteredKeyword.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context, isDark),
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? Localization.text(widget.selectedLanguage, 'coursePage')
              : Localization.text(widget.selectedLanguage, 'library'),
          style:
              const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedIndex == 0
            ? _buildCourseContent(isDark)
            : _buildLibraryContent(isDark),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          _drawerItem(Icons.book_rounded, "Courses", 0, isDark),
          _drawerItem(Icons.local_library_rounded, "Library", 1, isDark),
          const Spacer(),
          const Divider(indent: 20, endIndent: 20),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text("Logout",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
            onTap: () {},
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index, bool isDark) {
    bool selected = _selectedIndex == index;
    return ListTile(
      selected: selected,
      selectedTileColor: Colors.teal.withOpacity(0.1),
      leading: Icon(icon, color: selected ? Colors.teal : Colors.grey),
      title: Text(title,
          style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.teal : null)),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCourseContent(bool isDark) {
    final routes = _getSubjectRoutes(); // Fetch routes

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildSearchBar(isDark),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Localization.text(widget.selectedLanguage, 'chooseSubject'),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              Icon(Icons.sort_rounded, color: Colors.teal.shade700),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: _filteredSubjects.isNotEmpty
                ? GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredSubjects.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final item = _filteredSubjects[index];
                      final key = item['nameKey'];

                      return GestureDetector(
                        onTap: () {
                          // --- RESTORED NAVIGATION LOGIC ---
                          if (routes.containsKey(key)) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => routes[key]!),
                            );
                          }
                        },
                        child: _buildSubjectCard(
                          Localization.text(widget.selectedLanguage, key),
                          item['icon'],
                          item['color'],
                          isDark,
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 80, color: Colors.grey.withOpacity(0.5)),
                      const Text("No subjects match your search",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  )),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _runFilter,
        decoration: InputDecoration(
          hintText:
              Localization.text(widget.selectedLanguage, 'searchsubjects'),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.teal),
          filled: true,
          fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(
      String title, IconData icon, Color color, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? color.withOpacity(0.15) : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withOpacity(0.2), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 38),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLibraryContent(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child:
                  const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
            ),
            title: Text("Reference Material ${index + 1}",
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text("Grade 12 • Chemistry • 5.2 MB",
                style: TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.download_for_offline_rounded,
                  color: Colors.teal),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}

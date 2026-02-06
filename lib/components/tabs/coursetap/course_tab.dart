import 'package:flutter/material.dart';
import '../../utils/localization.dart';

// --- Subject Page Imports ---
import 'package:eduhub/components/tabs/coursetap/subject/art_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/biology_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/chemistry_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/english_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/geography_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/history_page.dart';
import 'package:eduhub/components/tabs/coursetap/subject/math_page.dart';
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
  
  // 1. ADD SEARCH CONTROLLER AND FILTERED LIST
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSubjects = [];

  final List<Map<String, dynamic>> _allSubjects = [
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

  @override
  void initState() {
    super.initState();
    // Initialize the filtered list with all subjects
    _filteredSubjects = _allSubjects;
  }

  // 2. SEARCH LOGIC FUNCTION
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allSubjects;
    } else {
      results = _allSubjects.where((subject) {
        // We search based on the translated text
        String translatedName = Localization.text(widget.selectedLanguage, subject['nameKey']).toLowerCase();
        return translatedName.contains(enteredKeyword.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredSubjects = results;
    });
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? Localization.text(widget.selectedLanguage, 'coursePage')
              : "Library",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.teal.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: _selectedIndex == 0 ? _buildCourseContent() : _buildLibraryContent(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.teal.shade700),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.teal, size: 40),
            ),
            accountName: const Text("Student Name", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("student@eduhub.com"),
          ),
          ListTile(
            selected: _selectedIndex == 0,
            leading: const Icon(Icons.book_outlined),
            title: const Text("Course"),
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context); 
            },
          ),
          ListTile(
            selected: _selectedIndex == 1,
            leading: const Icon(Icons.local_library_outlined),
            title: const Text("Library"),
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context); 
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout"),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCourseContent() {
    final routes = _getSubjectRoutes();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildSearchBar(),
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
            child: _filteredSubjects.isNotEmpty 
              ? GridView.builder(
                  itemCount: _filteredSubjects.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final item = _filteredSubjects[index];
                    final key = item['nameKey'];
                    return GestureDetector(
                      onTap: () {
                        if (routes.containsKey(key)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => routes[key]!),
                          );
                        }
                      },
                      child: _buildSubjectCard(
                        Localization.text(widget.selectedLanguage, key),
                        item['icon'],
                        item['color'],
                      ),
                    );
                  },
                )
              : const Center(child: Text("No subjects found.")), // Empty state
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryContent() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          color: Colors.grey.shade50,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.red),
            ),
            title: Text("Reference Material ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("E-Book • 12.4 MB"),
            trailing: const Icon(Icons.download_for_offline, color: Colors.teal),
          ),
        );
      },
    );
  }

  // --- 3. UPDATED SEARCH BAR WITH ONCHANGED ---
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => _runFilter(value), // Call the filter function
      decoration: InputDecoration(
        hintText: Localization.text(widget.selectedLanguage, 'searchsubjects'),
        prefixIcon: const Icon(Icons.search, color: Colors.teal),
        suffixIcon: _searchController.text.isNotEmpty 
          ? IconButton(
              icon: const Icon(Icons.clear), 
              onPressed: () {
                _searchController.clear();
                _runFilter('');
              })
          : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
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
              border: Border.all(color: color.withOpacity(0.1), width: 1),
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
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }
}
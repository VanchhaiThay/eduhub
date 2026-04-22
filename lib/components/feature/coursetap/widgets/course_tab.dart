import 'package:flutter/material.dart';
import '../../../../utils/localization.dart';
import 'course_data.dart';
import 'course_drawer.dart';
import 'course_content.dart';
import 'course_library.dart';

class CourseTab extends StatefulWidget {
  final String selectedLanguage;
  const CourseTab({super.key, required this.selectedLanguage});

  @override
  State<CourseTab> createState() => _CourseTabState();
}

class _CourseTabState extends State<CourseTab> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late List<Map<String, dynamic>> _filteredSubjects;

  @override
  void initState() {
    super.initState();
    _filteredSubjects = List.from(CourseData.subjects);
  }

  void _runFilter(String enteredKeyword) {
    setState(() {
      if (enteredKeyword.isEmpty) {
        _filteredSubjects = List.from(CourseData.subjects);
      } else {
        _filteredSubjects = CourseData.subjects.where((subject) {
          String translatedName = Localization.text(widget.selectedLanguage, subject['nameKey']).toLowerCase();
          return translatedName.contains(enteredKeyword.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : Colors.grey.shade800;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: CourseDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? Localization.text(widget.selectedLanguage, 'coursePage')
              : Localization.text(widget.selectedLanguage, 'library'),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedIndex == 0
            ? CourseContent(
                filteredSubjects: _filteredSubjects,
                selectedLanguage: widget.selectedLanguage,
                searchController: _searchController,
                onSearchChanged: _runFilter,
              )
            : const CourseLibrary(),
      ),
    );
  }
}
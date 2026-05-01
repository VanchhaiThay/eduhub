import 'package:flutter/material.dart';
import 'package:eduhub/components/core/app_color.dart';
import '../../../../utils/localization.dart';
import 'course_data.dart';
import 'course_search.dart';
import 'course_card.dart';

class CourseContent extends StatelessWidget {
  final List<Map<String, dynamic>> filteredSubjects;
  final String selectedLanguage;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;

  const CourseContent({
    super.key,
    required this.filteredSubjects,
    required this.selectedLanguage,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = AppColors.getPrimaryColor(isDark);
    final routes = CourseData.getSubjectRoutes();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          CourseSearch(
            controller: searchController,
            onChanged: onSearchChanged,
            selectedLanguage: selectedLanguage,
          ),
          const SizedBox(height: 24),
          Text(
            Localization.text(selectedLanguage, 'ChooseSubject'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredSubjects.isNotEmpty
                ? GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredSubjects.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemBuilder: (context, index) {
                      final item = filteredSubjects[index];
                      final key = item['nameKey'];

                      return GestureDetector(
                        onTap: () {
                          if (routes.containsKey(key)) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => routes[key]!,
                              ),
                            );
                          }
                        },
                        child: CourseCard(
                          title: Localization.text(selectedLanguage, key),
                          icon: item['icon'],
                          color: item['color'],
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        Text(
                          "No subjects match your search",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

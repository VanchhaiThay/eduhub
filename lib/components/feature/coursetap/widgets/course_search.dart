import 'package:flutter/material.dart';
import 'package:eduhub/components/core/app_color.dart';
import '../../../../utils/localization.dart';

class CourseSearch extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String selectedLanguage;

  const CourseSearch({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = AppColors.getPrimaryColor(isDark);
    final Color searchBgColor = isDark ? Colors.grey.shade900 : Colors.grey.shade100;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: Localization.text(selectedLanguage, 'searchsubjects'),
          prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
          filled: true,
          fillColor: searchBgColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
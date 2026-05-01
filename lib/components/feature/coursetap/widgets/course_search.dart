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
    final Color searchBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: Localization.text(selectedLanguage, 'searchsubjects'),
          hintStyle: TextStyle(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
            fontSize: 14,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: primaryColor, size: 20),
          filled: true,
          fillColor: searchBgColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const CourseCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
            color: isDark ? Colors.white : Colors.grey.shade800,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String icon;
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
              color: isDark ? color.withOpacity(0.12) : color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? color.withOpacity(0.15)
                    : color.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isDark ? 0.1 : 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                icon,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported, color: color, size: 32),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

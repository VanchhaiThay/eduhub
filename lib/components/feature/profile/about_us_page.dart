import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF38A39D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.school_outlined,
                size: 50,
                color: const Color(0xFF38A39D),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'EduHub',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),
            _buildSection(
              'Our Mission',
              'EduHub is dedicated to providing a comprehensive educational platform that connects students, teachers, and parents. We strive to make learning accessible, engaging, and effective for everyone.',
              isDark,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'What We Offer',
              '• Interactive learning materials\n• Real-time assignment tracking\n• Teacher-student communication\n• Progress monitoring\n• Multi-language support',
              isDark,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Contact Us',
              'Have questions or feedback? We\'d love to hear from you!\n\nEmail: support@eduhub.com\nWebsite: www.eduhub.com',
              isDark,
            ),
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF38A39D).withOpacity(0.1)
                    : const Color(0xFF38A39D).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF38A39D).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.favorite,
                    color: const Color(0xFF38A39D),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Made with love for education',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 EduHub. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
              height: 1.6,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

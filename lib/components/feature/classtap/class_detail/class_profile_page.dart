import 'package:flutter/material.dart';
import 'class_detail_constants.dart';
import 'class_members_page.dart';

class ClassProfilePage extends StatelessWidget {
  final String className;
  final String classId;

  const ClassProfilePage({
    super.key,
    required this.className,
    required this.classId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = ClassDetailConstants.brandColor;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          'Class Profile',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F1117),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF0F1117),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Header Card ──────────────────────────────────────
            _HeroCard(className: className, brand: brand, isDark: isDark),

            const SizedBox(height: 28),

            // ── Sections ─────────────────────────────────────────────
            _buildSection(
              context,
              isDark: isDark,
              brand: brand,
              title: 'Class Management',
              options: [
                _MenuOption(
                  icon: Icons.people_alt_rounded,
                  title: 'Members',
                  subtitle: 'View and manage class members',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClassMembersPage(
                          classId: classId,
                          className: className,
                        ),
                      ),
                    );
                  },
                  isDark: isDark,
                ),
                _MenuOption(
                  icon: Icons.tune_rounded,
                  title: 'Settings',
                  subtitle: 'Class settings and preferences',
                  onTap: () => _showComingSoon(context, 'Settings'),
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              context,
              isDark: isDark,
              brand: brand,
              title: 'Communication',
              options: [
                _MenuOption(
                  icon: Icons.notifications_rounded,
                  title: 'Notifications',
                  subtitle: 'Manage notification settings',
                  onTap: () => _showComingSoon(context, 'Notifications'),
                  isDark: isDark,
                ),
                _MenuOption(
                  icon: Icons.chat_bubble_rounded,
                  title: 'Chat Settings',
                  subtitle: 'Configure chat preferences',
                  onTap: () => _showComingSoon(context, 'Chat Settings'),
                  isDark: isDark,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              context,
              isDark: isDark,
              brand: brand,
              title: 'Information',
              options: [
                _MenuOption(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  subtitle: 'Class information and details',
                  onTap: () => _showComingSoon(context, 'About'),
                  isDark: isDark,
                ),
                _MenuOption(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'Get help with class features',
                  onTap: () => _showComingSoon(context, 'Help & Support'),
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required bool isDark,
    required Color brand,
    required String title,
    required List<_MenuOption> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: brand,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.45)
                      : Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1D27) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            children: [
              for (int i = 0; i < options.length; i++) ...[
                _buildMenuTile(context, options[i], brand, isDark),
                if (i < options.length - 1)
                  Divider(
                    height: 1,
                    indent: 68,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    _MenuOption option,
    Color brand,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: option.onTap,
        splashColor: brand.withValues(alpha: 0.06),
        highlightColor: brand.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: brand.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(option.icon, color: brand, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F1117),
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.45)
                            : Colors.black.withValues(alpha: 0.45),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          feature,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Text(
          '$feature features are coming soon.',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(
                color: ClassDetailConstants.brandColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Header Widget ─────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final String className;
  final Color brand;
  final bool isDark;

  const _HeroCard({
    required this.className,
    required this.brand,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final initials = className.isNotEmpty ? className[0].toUpperCase() : 'C';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1D27) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Column(
        children: [
          // Avatar with gradient ring
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      brand,
                      brand.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1A1D27) : Colors.white,
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? const Color(0xFF0F1117)
                      : brand.withValues(alpha: 0.08),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: brand,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            className,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              color: isDark ? Colors.white : const Color(0xFF0F1117),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isDark;

  const _StatChip({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _MenuOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const _MenuOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:eduhub/components/home/home.dart';
import 'package:eduhub/utils/auth_flow_manager.dart';
import 'package:eduhub/services/time_tracker_service.dart';

class LogoutButton extends StatelessWidget {
  final BuildContext pageContext;

  const LogoutButton({super.key, required this.pageContext});

  void _showLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Sign Out",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to sign out?",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // End time tracking before logout
                final timeTrackerService = TimeTrackerService();
                await timeTrackerService.endTimeTracking();
              } catch (e) {
                // Continue with logout even if time tracking fails
                print('Failed to end time tracking during logout: $e');
              }

              await auth.FirebaseAuth.instance.signOut();
              await AuthFlowManager.setStayOnHomeAfterLogout(true);
              if (pageContext.mounted) {
                Navigator.pushAndRemoveUntil(
                  pageContext,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Sign Out",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? Colors.red.shade800 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.red.withOpacity(0.3) : Colors.red.shade200,
            width: 1,
          ),
        ),
        child: TextButton.icon(
          onPressed: () => _showLogoutDialog(context),
          icon: Icon(
            Icons.logout_rounded,
            color: isDark ? Colors.red.shade300 : Colors.red.shade700,
            size: 20,
          ),
          label: Text(
            "Sign Out",
            style: TextStyle(
              color: isDark ? Colors.red.shade300 : Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: -0.2,
            ),
          ),
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

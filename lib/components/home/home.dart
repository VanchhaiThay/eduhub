import 'package:eduhub/components/home/services/home_notification_service.dart';
import 'package:eduhub/components/home/widgets/bottom_nav_bar.dart';
import 'package:eduhub/components/home/widgets/custom_app_bar.dart';
import 'package:eduhub/components/home/widgets/adaptive_app_bar.dart';
import 'package:eduhub/constants/app/asset_app.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../feature/hometap/home_students/home_student_tap.dart';
import '../feature/hometap/home_guest_tap.dart';
import '../feature/hometap/home_teacher/home_teacher_tab.dart';
import '../feature/coursetap/widgets/course_tab.dart';
import '../feature/classtap/classteacher/class_teacher_tab.dart';
import '../feature/classtap/classstudents/class_student_tab.dart';
import '../feature/assignmentstap/assignment_teacher_tab.dart';
import '../feature/assignmentstap/assignment_student_tab.dart';
import '../feature/profile/profile_tab.dart';
import '../feature/auth_prompt/class_auth_prompt.dart';
import '../feature/auth_prompt/assignment_auth_prompt.dart';
import '../../services/time_tracker_service.dart';

class HomePage extends StatefulWidget {
  final int initialNotification;
  const HomePage({super.key, this.initialNotification = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int notificationCount = 0;
  String? role;
  String? firstName;
  String? lastName;
  String? email;
  String selectedLanguage = "English";
  bool isLoading = true;
  String? photoUrl;

  // GlobalKey to access HomeTeacherTabState
  final GlobalKey<HomeTeacherTabState> _homeTeacherKey =
      GlobalKey<HomeTeacherTabState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (mounted) {
        // If user becomes null (logged out), end time tracking
        if (user == null) {
          try {
            final timeTrackerService = TimeTrackerService();
            await timeTrackerService.endTimeTracking();
          } catch (e) {
            print('Failed to end time tracking during auth state change: $e');
          }
        }
        _loadUserData();
      }
    });
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // No user logged in - set empty state
      if (mounted) {
        setState(() {
          role = null;
          firstName = null;
          lastName = null;
          email = null;
          selectedLanguage = "English";
          photoUrl = null;
          notificationCount = 0;
          isLoading = false;
        });
      }
      return;
    }

    final data = await HomeNotificationService.loadUserDataAndNotifications();
    if (data['error'] == null && mounted) {
      setState(() {
        role = data['role'];
        firstName = data['firstName'];
        lastName = data['lastName'];
        email = data['email'];
        selectedLanguage = data['selectedLanguage'];
        photoUrl = data['photoUrl'];
        notificationCount = data['notificationCount'];
      });
      if (mounted) isLoading = false;
    } else if (mounted) {
      isLoading = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error loading user data")));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showNotifications() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      await HomeNotificationService.showNotifications(
        context,
        uid: user.uid,
        onCountUpdate: (count) => setState(() => notificationCount = count),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final tabs = [
      role == 'teacher'
          ? HomeTeacherTab(
              key: _homeTeacherKey,
              language: selectedLanguage,
              onLearnMore: () => setState(() => _selectedIndex = 1),
            )
          : role == null
              ? HomeGuestTab(
                  language: selectedLanguage,
                  onLearnMore: () => setState(() => _selectedIndex = 1),
                )
              : HomeStudentTab(
                  language: selectedLanguage,
                  onLearnMore: () => setState(() => _selectedIndex = 1),
                ),
      CourseTab(selectedLanguage: selectedLanguage),
      role == 'teacher'
          ? ClassTeacherTab(language: selectedLanguage)
          : role == null
              ? ClassAuthPrompt(
                  selectedLanguage: selectedLanguage, isDark: isDark)
              : ClassStudentTab(language: selectedLanguage),
      role == 'teacher'
          ? AssignmentTeacherTab(language: selectedLanguage)
          : role == null
              ? AssignmentAuthPrompt(
                  selectedLanguage: selectedLanguage,
                  isDark: isDark,
                )
              : AssignmentStudentTab(language: selectedLanguage),
      ProfileTab(
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        selectedLanguage: selectedLanguage,
        onLanguageChanged: (lang) => setState(() => selectedLanguage = lang),
      ),
    ];

    final navItems = [
      BottomNavigationBarItem(
        icon: Image.asset(
          AppAssets.home,
          width: _selectedIndex == 0 ? 28 : 24,
          height: _selectedIndex == 0 ? 28 : 24,
          color: _selectedIndex == 0 ? const Color(0xFF2B827D) : Colors.grey,
        ),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          AppAssets.course,
          width: _selectedIndex == 1 ? 28 : 24,
          height: _selectedIndex == 1 ? 28 : 24,
          color: _selectedIndex == 1 ? const Color(0xFF2B827D) : Colors.grey,
        ),
        label: 'Course',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          AppAssets.classIcon,
          width: _selectedIndex == 2 ? 28 : 24,
          height: _selectedIndex == 2 ? 28 : 24,
          color: _selectedIndex == 2 ? const Color(0xFF2B827D) : Colors.grey,
        ),
        label: 'Class',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          AppAssets.assignment,
          width: _selectedIndex == 3 ? 28 : 24,
          height: _selectedIndex == 3 ? 28 : 24,
          color: _selectedIndex == 3 ? const Color(0xFF2B827D) : Colors.grey,
        ),
        label: 'Assignments',
      ),
      BottomNavigationBarItem(
        icon: Image.asset(
          AppAssets.profile,
          width: _selectedIndex == 4 ? 28 : 24,
          height: _selectedIndex == 4 ? 28 : 24,
          color: _selectedIndex == 4 ? const Color(0xFF2B827D) : Colors.grey,
        ),
        label: 'Profile',
      ),
    ];

    return Scaffold(
      appBar: AdaptiveAppBar(
        selectedIndex: _selectedIndex,
        firstName: firstName,
        lastName: lastName,
        email: email,
        role: role,
        photoUrl: photoUrl,
        notificationCount: notificationCount,
        onProfileTap: () => setState(() => _selectedIndex = 4),
        onNotificationTap: _showNotifications,
        isDark: isDark,
      ),
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        isDark: isDark,
        items: navItems,
      ),
    );
  }
}

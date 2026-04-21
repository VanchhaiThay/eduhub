import 'package:eduhub/components/home/services/home_notification_service.dart';
import 'package:eduhub/components/home/widgets/bottom_nav_bar.dart';
import 'package:eduhub/components/home/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../feature/hometap/home_students/home_student_tap.dart';
import '../feature/hometap/home_teacher/home_teacher_tab.dart';
import '../feature/coursetap/widgets/course_tab.dart';
import '../feature/classtap/classteacher/class_teacher_tab.dart';
import '../feature/classtap/classstudents/class_student_tab.dart';
import '../feature/assignmentstap/assignment_teacher_tab.dart';
import '../feature/assignmentstap/assignment_student_tab.dart';
import '../feature/profile/profile_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required int initialNotification});

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
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
          : ClassStudentTab(language: selectedLanguage),
      role == 'teacher'
          ? AssignmentTeacherTab(language: selectedLanguage)
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
        icon: Icon(Icons.home, size: _selectedIndex == 0 ? 28 : 24),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.book, size: _selectedIndex == 1 ? 28 : 24),
        label: 'Course',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.school, size: _selectedIndex == 2 ? 28 : 24),
        label: 'Class',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment, size: _selectedIndex == 3 ? 28 : 24),
        label: 'Assignments',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person, size: _selectedIndex == 4 ? 28 : 24),
        label: 'Profile',
      ),
    ];

    return Scaffold(
      appBar: CustomAppBar(
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

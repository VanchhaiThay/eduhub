import 'package:eduhub/components/tabs/assignmentstap/assignment_student_tab.dart';
import 'package:eduhub/components/tabs/classtap/class_student_tab.dart';
import 'package:eduhub/components/tabs/hometap/home_student_tap.dart';
import 'package:eduhub/components/tabs/hometap/home_teacher_tab.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/signin.dart';
import 'tabs/coursetap/course_tab.dart';
import 'tabs/classtap/class_teacher_tab.dart';
import 'tabs/assignmentstap/assignment_teacher_tab.dart';
import 'tabs/profile/profile_tab.dart';
import 'utils/user_data.dart';
import 'utils/localization.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? role;
  String? firstName;
  String? lastName;
  String? email;
  String selectedLanguage = "English"; // Default
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserData.loadUser();
    if (userData != null) {
      setState(() {
        role = userData.role;
        firstName = userData.firstName;
        lastName = userData.lastName;
        email = userData.email;
        selectedLanguage = userData.language ?? "English";
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading user data")),
      );
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Build tabs dynamically based on role
final tabs = [
  role == 'teacher'
      ? HomeTeacherTab(language: selectedLanguage)
      : HomeStudentTab(language: selectedLanguage),

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
    onLanguageChanged: (lang) {
      setState(() => selectedLanguage = lang);
    },
  ),
];


    return Scaffold(
      appBar: AppBar(
        title: const Text("EduHub"),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: Localization.text(selectedLanguage, 'home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.school),
            label: Localization.text(selectedLanguage, 'course'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.book),
            label: Localization.text(selectedLanguage, 'class'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment),
            label: Localization.text(selectedLanguage, 'assignments'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: Localization.text(selectedLanguage, 'profile'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/signin.dart';

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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          role = doc['role']; // student or teacher
          firstName = doc['firstName'];
          lastName = doc['lastName'];
          email = doc['email'];
          isLoading = false;
        });
      } else {
        throw Exception("User data not found");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading user: $e")));
      setState(() => isLoading = false);
    }
  }

  // Logout
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // Bottom nav tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Tabs based on role
  List<Widget> _buildTabs() {
    if (role == 'teacher') {
      return [
        const Center(child: Text("Home Screen (Teacher)")), // Home
        _buildCourseTab(), // Course
        const Center(child: Text("My Classes")), // Class
        const Center(child: Text("Assignments to Grade")), // Assignment
        _buildProfileTab(), // Profile
      ];
    } else {
      // Student
      return [
        const Center(child: Text("Home Screen (Student)")), // Home
        _buildCourseTab(), // Course
        const Center(child: Text("Enrolled Classes")), // Class
        const Center(child: Text("My Assignments")), // Assignment
        _buildProfileTab(), // Profile
      ];
    }
  }

  // Profile tab
  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("First Name: $firstName", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text("Last Name: $lastName", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text("Email: $email", style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          Text("Role: $role", style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  // Course tab
  Widget _buildCourseTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Hello from course"),
        ],
      ),
    );
  }

  // Bottom nav items
  List<BottomNavigationBarItem> _buildBottomNavItems() {
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.school), label: "Course"),
      BottomNavigationBarItem(icon: Icon(Icons.book), label: "Class"),
      BottomNavigationBarItem(
        icon: Icon(Icons.assignment),
        label: "Assignments",
      ),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final tabs = _buildTabs();
    final navItems = _buildBottomNavItems();

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
        items: navItems,
        onTap: _onItemTapped,
      ),
    );
  }
}

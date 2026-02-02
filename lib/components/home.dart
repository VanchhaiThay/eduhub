import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../auth/signin.dart';
import '../main.dart'; // flutterLocalNotificationsPlugin
import 'tabs/hometap/home_student_tap.dart';
import 'tabs/hometap/home_teacher_tab.dart';
import 'tabs/coursetap/course_tab.dart';
import 'tabs/classtap/class_teacher_tab.dart';
import 'tabs/classtap/class_student_tab.dart';
import 'tabs/assignmentstap/assignment_teacher_tab.dart';
import 'tabs/assignmentstap/assignment_student_tab.dart';
import 'tabs/profile/profile_tab.dart';
import 'utils/user_data.dart';
import 'utils/localization.dart';

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
  String selectedLanguage = "English"; // Default
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndNotifications();
  }

  /// Load user data and notification count
  Future<void> _loadUserDataAndNotifications() async {
    final userData = await UserData.loadUser();
    final user = FirebaseAuth.instance.currentUser;

    if (userData != null && user != null) {
      setState(() {
        role = userData.role;
        firstName = userData.firstName;
        lastName = userData.lastName;
        email = userData.email;
        selectedLanguage = userData.language ?? "English";
      });

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await userRef.get();

      int currentCount = 0;
      if (doc.exists) {
        currentCount = (doc.data()?['notificationCount'] ?? 0) as int;
        setState(() => notificationCount = currentCount);
      }

      // Increment notification only if not incremented yet
      if (currentCount == 0) {
        await _incrementLoginNotification(user.uid);
      }

      setState(() => isLoading = false);
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading user data")),
      );
    }
  }

  /// Increment notification on login
  Future<void> _incrementLoginNotification(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    // Transaction ensures safety in multi-device scenarios
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentCount = snapshot.data()?['notificationCount'] ?? 0;
      transaction.update(userRef, {'notificationCount': currentCount + 1});
      setState(() => notificationCount = currentCount + 1);
    });

    // Store notification details
    await userRef.update({
      'notifications': FieldValue.arrayUnion([
        {
          'title': 'Welcome Back!',
          'body': 'You logged in successfully',
          'timestamp': Timestamp.now(),
        }
      ])
    });

    // Show local notification
    const androidDetails = AndroidNotificationDetails(
      'login_channel',
      'Login Notifications',
      channelDescription: 'Login alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

await flutterLocalNotificationsPlugin.show( id:DateTime.now().millisecondsSinceEpoch ~/ 1000, title: 'Welcome Back!', body: 'Hello, you logged in successfully!', notificationDetails: notificationDetails, payload: 'login_notification', );
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

  /// Clear notifications when tapping the bell
  void _onNotificationPressed() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => notificationCount = 0);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'notificationCount': 0});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
        onLanguageChanged: (lang) => setState(() => selectedLanguage = lang),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF38A39D),
        title: Row(
          children: [
            const CircleAvatar(radius: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${firstName ?? ""} ${lastName ?? ""}",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    role != null ? role!.toUpperCase() : "",
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _onNotificationPressed,
                icon: const Icon(Icons.notifications, color: Colors.white),
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                        color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$notificationCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
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

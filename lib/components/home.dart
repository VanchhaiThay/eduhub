import 'dart:io';
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
  String selectedLanguage = "English";
  bool isLoading = true;

  File? profileImage;
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadUserDataAndNotifications();
  }

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

      if (doc.exists) {
        final data = doc.data()!;
        notificationCount = (data['notificationCount'] ?? 0) as int;
        notifications = List<Map<String, dynamic>>.from(data['notifications'] ?? []);
      }

      if (notificationCount == 0) {
        await _incrementLoginNotification(user.uid);
      }

      setState(() => isLoading = false);
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Error loading user data")));
    }
  }

  Future<void> _incrementLoginNotification(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentCount = snapshot.data()?['notificationCount'] ?? 0;
      transaction.update(userRef, {'notificationCount': currentCount + 1});
      setState(() => notificationCount = currentCount + 1);
    });

    final newNotification = {
      'title': 'EduHub welcome!',
      'body': 'You logged in successfully',
      'timestamp': Timestamp.now(),
    };

    await userRef.update({
      'notifications': FieldValue.arrayUnion([newNotification])
    });

    setState(() {
      notifications.insert(0, newNotification);
    });

    const androidDetails = AndroidNotificationDetails(
      'login_channel',
      'Login Notifications',
      channelDescription: 'Login alerts',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Welcome Back!',
      body: 'Hello, eduhub can help you improve more!',
      notificationDetails: notificationDetails,
      payload: 'login_notification',
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => notificationCount = 0);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'notificationCount': 0});

    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 400,
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Notifications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: notifications.isEmpty
                  ? const Center(child: Text("No notifications"))
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        final ts = notif['timestamp'] as Timestamp?;
                        final dateStr = ts != null
                            ? "${ts.toDate().hour}:${ts.toDate().minute}, ${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}"
                            : "";
                        return ListTile(
                          title: Text(notif['title'] ?? ""),
                          subtitle: Text(notif['body'] ?? ""),
                          trailing: Text(dateStr, style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
        elevation: 0,
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1F1F1F), const Color(0xFF2C2C2C)]
                  : [const Color(0xFF38A39D), const Color(0xFF2B827D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _selectedIndex = 4),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      profileImage != null ? FileImage(profileImage!) : null,
                  child: profileImage == null
                      ? Text(
                          "${firstName?[0] ?? ""}${lastName?[0] ?? ""}",
                          style: const TextStyle(
                            color: Color(0xFF38A39D),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${firstName ?? ""} ${lastName ?? ""}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white30, width: 0.5),
                    ),
                    child: Text(
                      role?.toUpperCase() ?? "",
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: _showNotifications,
                  icon: const Icon(Icons.notifications_none_rounded,
                      color: Colors.white, size: 28),
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 10,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: isDark
                                ? const Color(0xFF1F1F1F)
                                : const Color(0xFF38A39D),
                            width: 1.5),
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: tabs[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: const Color(0xFF2B827D),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: _selectedIndex == 0 ? 28 : 24,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.school,
                size: _selectedIndex == 1 ? 28 : 24,
              ),
              label: 'Course',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.book,
                size: _selectedIndex == 2 ? 28 : 24,
              ),
              label: 'Class',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.assignment,
                size: _selectedIndex == 3 ? 28 : 24,
              ),
              label: 'Assignments',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: _selectedIndex == 4 ? 28 : 24,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

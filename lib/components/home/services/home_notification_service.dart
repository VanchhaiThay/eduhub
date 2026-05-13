import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../utils/user_data.dart';
import '../../../main.dart'; // flutterLocalNotificationsPlugin

class HomeNotificationService {
  static int notificationCount = 0;
  static List<Map<String, dynamic>> notifications = [];

  static Future<Map<String, dynamic>> loadUserDataAndNotifications() async {
    final userData = await UserData.loadUser();
    final user = FirebaseAuth.instance.currentUser;

    if (userData == null || user == null) {
      return {'error': 'Error loading user data'};
    }

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (doc.exists) {
      final data = doc.data()!;
      notificationCount = (data['notificationCount'] ?? 0) as int;
      notifications = List<Map<String, dynamic>>.from(
        data['notifications'] ?? [],
      );
    }

    if (notificationCount == 0) {
      await _incrementLoginNotification(user.uid);
    }

    return {
      'role': userData.role,
      'firstName': userData.firstName,
      'lastName': userData.lastName,
      'email': userData.email,
      'photoUrl': user.photoURL,
      'notificationCount': notificationCount,
      'notifications': notifications,
      'selectedLanguage': userData.language ?? 'English',
    };
  }

  static Future<void> _incrementLoginNotification(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentCount = snapshot.data()?['notificationCount'] ?? 0;
      transaction.update(userRef, {'notificationCount': currentCount + 1});
      notificationCount = currentCount + 1;
    });

    final newNotification = {
      'title': 'EduHub welcome!',
      'body': 'You logged in successfully',
      'timestamp': Timestamp.now(),
    };

    await userRef.update({
      'notifications': FieldValue.arrayUnion([newNotification]),
    });

    notifications.insert(0, newNotification);

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

  static Future<void> showNotifications(
    BuildContext context, {
    required String uid,
    required Function(int) onCountUpdate,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'notificationCount': 0,
    });

    onCountUpdate(0);

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
                          trailing: Text(
                            dateStr,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static void clearNotifications() {
    notificationCount = 0;
    notifications.clear();
  }
}

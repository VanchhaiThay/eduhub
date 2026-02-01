import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String? role;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? language;

  UserData({this.role, this.firstName, this.lastName, this.email, this.language});

  static Future<UserData?> loadUser() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        return UserData(
          role: data?['role'],
          firstName: data?['firstName'],
          lastName: data?['lastName'],
          email: data?['email'],
          language: data?['language'],
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveLanguage(String language) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection("users").doc(uid).update({'language': language});
    } catch (e) {
      // ignore error
    }
  }
}

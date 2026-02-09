import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eduhub/components/tabs/classtap/classteacher/class_detail_page.dart';

class ClassStudentTab extends StatefulWidget {
  final String language;

  const ClassStudentTab({super.key, required this.language});

  @override
  State<ClassStudentTab> createState() => _ClassStudentTabState();
}

class _ClassStudentTabState extends State<ClassStudentTab> {
  final TextEditingController _codeController = TextEditingController();
  final Color primaryColor = const Color(0xFF38A39D);

  bool _isJoining = false;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ================= JOIN CLASS =================

  Future<void> _joinClass() async {
    String code = _codeController.text.trim().toUpperCase();

    if (code.length != 6) {
      _showStatus("Enter a valid 6-digit code", isError: true);
      return;
    }

    setState(() => _isJoining = true);

    try {
      var lookupDoc = await FirebaseFirestore.instance
          .collection("class_lookup")
          .doc(code)
          .get();

      if (!lookupDoc.exists) {
        throw "Class code not found!";
      }

      var data = lookupDoc.data()!;
      String teacherId = data['teacherId'];
      String classId = data['classId'];
      String className = data['className'];

      final user = FirebaseAuth.instance.currentUser!;
      final userName =
          user.displayName ?? user.email ?? "Student";

      // Add student to teacher class
      await FirebaseFirestore.instance
          .collection("users")
          .doc(teacherId)
          .collection("classes")
          .doc(classId)
          .collection("students")
          .doc(uid)
          .set({
        "uid": uid,
        "name": userName,
        "joinedAt": FieldValue.serverTimestamp(),
      });

      // Save class in student account
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("enrolled_classes")
          .doc(classId)
          .set({
        "classId": classId,
        "teacherId": teacherId,
        "className": className,
        "joinCode": code,
      });

      _codeController.clear();

      if (mounted) Navigator.pop(context);

      _showStatus("$userName joined $className");

      // Open class page
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClassDetailPage(
              className: className,
              classId: classId,
            ),
          ),
        );
      }
    } catch (e) {
      _showStatus(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  void _showStatus(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : primaryColor,
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showJoinDialog,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("enrolled_classes")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final classes = snapshot.data?.docs ?? [];

          if (classes.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) =>
                _buildClassCard(classes[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined,
              size: 100, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("No classes joined yet",
              style:
                  TextStyle(color: Colors.grey[600], fontSize: 18)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _showJoinDialog,
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor),
            child: const Text("Join Your First Class",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: primaryColor.withOpacity(0.1),
          child: Icon(Icons.class_, color: primaryColor),
        ),
        title: Text(data['className'],
            style:
                const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Code: ${data['joinCode']}"),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClassDetailPage(
                className: data['className'],
                classId: data['classId'],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Join Class"),
        content: TextField(
          controller: _codeController,
          maxLength: 6,
          textCapitalization:
              TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: "Enter 6-digit code",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: _isJoining ? null : _joinClass,
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor),
            child: _isJoining
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white),
                  )
                : const Text("Join",
                    style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

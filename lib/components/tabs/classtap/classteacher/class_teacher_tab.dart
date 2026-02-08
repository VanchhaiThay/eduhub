import 'package:eduhub/components/tabs/classtap/classteacher/class_detail_page.dart';
import 'package:eduhub/components/utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ClassTeacherTab extends StatefulWidget {
  final String language;

  const ClassTeacherTab({super.key, required this.language});

  @override
  State<ClassTeacherTab> createState() => _ClassTeacherTabState();
}

class _ClassTeacherTabState extends State<ClassTeacherTab> {
  final classNameController = TextEditingController();
  final subjectController = TextEditingController();

  bool isLoading = false;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> createClass() async {
    if (classNameController.text.isEmpty ||
        subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("classes")
          .add({
        "className": classNameController.text.trim(),
        "subject": subjectController.text.trim(),
        "createdAt": Timestamp.now(),
      });

      classNameController.clear();
      subjectController.clear();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Class created")));
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    classNameController.dispose();
    subjectController.dispose();
    super.dispose();
  }

  void showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Class"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: classNameController,
              decoration: const InputDecoration(labelText: "Class Name"),
            ),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: "Subject"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await createClass();
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  Widget buildClassList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("classes")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var classes = snapshot.data!.docs;

        if (classes.isEmpty) {
          return const Center(child: Text("No classes yet"));
        }

        return ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, index) {
            var data = classes[index];

            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.class_),
                title: Text(data["className"]),
                subtitle: Text("Subject: ${data["subject"]}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClassDetailPage(
                        className: data["className"],
                        subject: data["subject"],
                        classId: data.id,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: showCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            Localization.text(widget.language, "welcomeTitle"),
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(height: 10),
          Expanded(child: buildClassList()),
        ],
      ),
    );
  }
}

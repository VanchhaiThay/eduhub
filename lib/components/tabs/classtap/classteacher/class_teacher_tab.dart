import 'dart:math';
import 'package:eduhub/components/tabs/classtap/classteacher/class_detail_page.dart';
import 'package:eduhub/components/utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool isLoading = false;

  String get uid => FirebaseAuth.instance.currentUser!.uid;
  final Color primaryColor = const Color(0xFF38A39D);

  // --- Firebase Operations ---

  Future<void> createClass() async {
    if (classNameController.text.isEmpty) {
      _showStatus("Please enter a class name", isError: true);
      return;
    }
    setState(() => isLoading = true);
    try {
      final joinCode = _generateJoinCode();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("classes")
          .add({
        "className": classNameController.text.trim(),
        "joinCode": joinCode,
        "joinLink": "https://eduhub.app/join/$joinCode",
        "createdAt": Timestamp.now(),
        "studentCount": 0,
      });
      classNameController.clear();
      _showStatus("Class created successfully!");
    } catch (e) {
      _showStatus("Error: $e", isError: true);
    }
    setState(() => isLoading = false);
  }

  Future<void> updateClassName(String classId, String newName) async {
    if (newName.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("classes")
          .doc(classId)
          .update({"className": newName.trim()});
      _showStatus("Class updated!");
    } catch (e) {
      _showStatus("Update failed", isError: true);
    }
  }

  Future<void> deleteClass(String classId) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("classes")
          .doc(classId)
          .delete();
      _showStatus("Class deleted", isError: true);
    } catch (e) {
      _showStatus("Delete failed", isError: true);
    }
  }

  // --- UI Helpers ---

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
  }

  void _showStatus(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.redAccent : primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- Dialogs ---

  void showEditDialog(String classId, String currentName) {
    classNameController.text = currentName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Class Name"),
        content: _buildDialogField(classNameController, "Class Name", Icons.edit_outlined),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              updateClassName(classId, classNameController.text);
              Navigator.pop(context);
              classNameController.clear();
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showDeleteConfirmation(String classId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Class?"),
        content: const Text("This action cannot be undone. All class data will be lost."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              deleteClass(classId);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showCreateDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Create New Class", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              content: _buildDialogField(classNameController, "Class Name", Icons.class_outlined),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () async {
                    Navigator.pop(context);
                    await createClass();
                  },
                  child: const Text("Create", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showCreateDialog,
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("New Class", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(Localization.text(widget.language, "welcomeTitle"),
                  style: const TextStyle(color: Color.fromARGB(255, 3, 0, 0), fontWeight: FontWeight.bold, fontSize: 18)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.8)]),
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("classes")
                .orderBy("createdAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
              var classes = snapshot.data?.docs ?? [];
              if (classes.isEmpty) {
                return const SliverFillRemaining(child: Center(child: Text("No classes yet")));
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildProfessionalClassCard(classes[index]),
                    childCount: classes.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalClassCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClassDetailPage(className: data["className"], classId: doc.id),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.class_rounded, color: primaryColor),
                      ),
                      // --- Popup Menu for Edit/Delete ---
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                        onSelected: (value) {
                          if (value == 'edit') {
                            showEditDialog(doc.id, data["className"]);
                          } else if (value == 'delete') {
                            showDeleteConfirmation(doc.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text("Edit Name")),
                          const PopupMenuItem(value: 'delete', child: Text("Delete Class", style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    data["className"],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
                  ),
                  Divider(height: 30, color: isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniInfo(Icons.people_alt_outlined, "${data['studentCount'] ?? 0} Students"),
                      _buildJoinBadge(data['joinCode'] ?? "N/A"),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, size: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: isDarkMode ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildJoinBadge(String code) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        _showStatus("Join code copied!");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),
        child: Text("Code: $code", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }
}
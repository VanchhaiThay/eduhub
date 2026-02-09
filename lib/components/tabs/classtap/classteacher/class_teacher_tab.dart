import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:eduhub/components/tabs/classtap/classteacher/class_detail_page.dart';
import 'package:eduhub/components/utils/localization.dart';

class ClassTeacherTab extends StatefulWidget {
  final String language;

  const ClassTeacherTab({super.key, required this.language});

  @override
  State<ClassTeacherTab> createState() => _ClassTeacherTabState();
}

class _ClassTeacherTabState extends State<ClassTeacherTab> {
  final classNameController = TextEditingController();
  bool isLoading = false;
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // Primary brand color stays consistent
  final Color brandColor = const Color(0xFF38A39D);

  @override
  void dispose() {
    classNameController.dispose();
    super.dispose();
  }

  // ================= LOGIC =================

  Future<void> createClass() async {
    if (uid == null) return;
    final name = classNameController.text.trim();
    if (name.isEmpty) {
      _showStatus("Please enter a class name", isError: true);
      return;
    }

    setState(() => isLoading = true);
    try {
      final joinCode = _generateJoinCode();
      final classRef = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("classes")
          .add({
        "className": name,
        "joinCode": joinCode,
        "createdAt": Timestamp.now(),
        "studentCount": 0,
      });

      await FirebaseFirestore.instance
          .collection("class_lookup")
          .doc(joinCode)
          .set({
        "teacherId": uid,
        "classId": classRef.id,
        "className": name,
      });

      classNameController.clear();
      _showStatus("Class '$name' created!");
    } catch (e) {
      _showStatus("Error creating class", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> deleteClass(String classId, String joinCode) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("classes")
          .doc(classId)
          .delete();
      await FirebaseFirestore.instance
          .collection("class_lookup")
          .doc(joinCode)
          .delete();
      _showStatus("Class deleted", isError: true);
    } catch (e) {
      _showStatus("Failed to delete", isError: true);
    }
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(Random().nextInt(chars.length))),
    );
  }

  void _showStatus(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : brandColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  void showCreateDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("New Class", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: classNameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Class Name",
            hintText: "e.g. Science 101",
            filled: true,
            fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[500])),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              createClass();
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (uid == null) return const Center(child: Text("Authentication Required"));

    return Scaffold(
      // scaffoldBackgroundColor automatically handles dark/light if theme is set
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showCreateDialog,
        backgroundColor: brandColor,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("New Class", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(isDark),
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

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) return _buildEmptyState(theme);

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildClassCard(docs[index], theme, isDark),
                    childCount: docs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      stretch: true,
      backgroundColor: brandColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          Localization.text(widget.language, "welcomeTitle"),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [brandColor, brandColor.withOpacity(0.8)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(DocumentSnapshot doc, ThemeData theme, bool isDark) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data["className"] ?? "Unnamed Class";
    final code = data["joinCode"] ?? "000000";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.1), width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.school_rounded, color: brandColor),
          ),
          title: Text(
            name,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      color: brandColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text("Long press to copy", style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: theme.hintColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (val) => val == 'delete' ? deleteClass(doc.id, code) : null,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text("Edit Name")),
              const PopupMenuItem(
                value: 'delete',
                child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ClassDetailPage(className: name, classId: doc.id)),
          ),
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: code));
            HapticFeedback.mediumImpact();
            _showStatus("Code copied!");
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_rounded, size: 70, color: theme.hintColor.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            "Ready to teach?",
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Create your first class to get started",
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}
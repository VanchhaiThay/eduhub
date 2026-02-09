import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eduhub/components/tabs/classtap/classteacher/class_detail_page.dart';
import 'package:eduhub/components/utils/localization.dart';

class ClassStudentTab extends StatefulWidget {
  final String language;

  const ClassStudentTab({super.key, required this.language});

  @override
  State<ClassStudentTab> createState() => _ClassStudentTabState();
}

class _ClassStudentTabState extends State<ClassStudentTab> {
  final TextEditingController _codeController = TextEditingController();
  final Color brandColor = const Color(0xFF38A39D);

  bool _isJoining = false;
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ================= LOGIC =================

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
        throw "Invalid Class Code. Please check and try again.";
      }

      var data = lookupDoc.data()!;
      String teacherId = data['teacherId'];
      String classId = data['classId'];
      String className = data['className'];

      final user = FirebaseAuth.instance.currentUser!;
      final userName = user.displayName ?? user.email ?? "Student";

      // Write to both teacher's student list and student's enrolled list
      WriteBatch batch = FirebaseFirestore.instance.batch();

      DocumentReference teacherClassRef = FirebaseFirestore.instance
          .collection("users")
          .doc(teacherId)
          .collection("classes")
          .doc(classId)
          .collection("students")
          .doc(uid);

      DocumentReference studentEnrollRef = FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("enrolled_classes")
          .doc(classId);

      batch.set(teacherClassRef, {
        "uid": uid,
        "name": userName,
        "joinedAt": FieldValue.serverTimestamp(),
      });

      batch.set(studentEnrollRef, {
        "classId": classId,
        "teacherId": teacherId,
        "className": className,
        "joinCode": code,
      });

      await batch.commit();

      _codeController.clear();
      if (mounted) Navigator.pop(context);

      _showStatus("Successfully joined $className!");
      HapticFeedback.heavyImpact();

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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isError ? Colors.redAccent : brandColor,
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showJoinDialog,
        backgroundColor: brandColor,
        icon: const Icon(Icons.add_link_rounded, color: Colors.white),
        label: const Text("Join Class", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(isDark),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("enrolled_classes")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              final classes = snapshot.data?.docs ?? [];
              if (classes.isEmpty) return _buildEmptyState(theme);

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildClassCard(classes[index], theme, isDark),
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

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 110,
      pinned: true,
      backgroundColor: brandColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          Localization.text(widget.language, "enrolledClasses") ?? "My Classes",
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildClassCard(DocumentSnapshot doc, ThemeData theme, bool isDark) {
    var data = doc.data() as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: Colors.white10) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.school_rounded, color: brandColor),
          ),
          title: Text(
            data['className'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.dividerColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_right_rounded),
          ),
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
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.5,
              child: Icon(Icons.menu_book_rounded, size: 80, color: theme.hintColor),
            ),
            const SizedBox(height: 24),
            Text(
              "No classes joined",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Ask your teacher for a 6-digit code",
              style: TextStyle(color: theme.hintColor),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showJoinDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Join Class"),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text("Enter Class Code", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ask your teacher for the 6-digit code to join their classroom."),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              maxLength: 6,
              autofocus: true,
              style: const TextStyle(letterSpacing: 8, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                hintText: "ABC123",
                hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), letterSpacing: 2, fontSize: 18),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: _isJoining ? null : _joinClass,
            style: ElevatedButton.styleFrom(
              backgroundColor: brandColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _isJoining
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text("Join"),
          ),
        ],
      ),
    );
  }
}
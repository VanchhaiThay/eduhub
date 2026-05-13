import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eduhub/components/feature/classtap/class_detail/class_detail_page.dart';
import 'package:eduhub/utils/localization.dart';

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
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // ================= LOGIC =================

  Future<void> _joinClass() async {
    if (uid == null) {
      _showStatus("Please sign in to join classes", isError: true);
      return;
    }

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
            builder: (_) =>
                ClassDetailPage(className: className, classId: classId),
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

    // Check if user is logged in
    if (uid == null) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF111315) : const Color(0xFFF3F5F7),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_outlined,
                size: 80,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              Text(
                'No classes available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please sign in to join classes',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38A39D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF111315) : const Color(0xFFF3F5F7),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showJoinDialog,
        elevation: 0,
        backgroundColor: brandColor,
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.add_link_rounded, color: Colors.white, size: 20),
        label: const Text(
          "Join Class",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                Localization.text(widget.language, "My Classes"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(uid)
                .collection("enrolled_classes")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final classes = snapshot.data?.docs ?? [];
              if (classes.isEmpty) return _buildEmptyState(theme);

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildClassCard(classes[index], theme, isDark),
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

  Widget _buildClassCard(DocumentSnapshot doc, ThemeData theme, bool isDark) {
    var data = doc.data() as Map<String, dynamic>;
    final className = data['className']?.toString() ?? 'Class';
    final classId = data['classId']?.toString() ?? '';
    final joinCode = data['joinCode']?.toString() ?? '';
    final cardColor = isDark ? const Color(0xFF1C2023) : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE7ECEF),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : const Color(0x1A000000),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ClassDetailPage(className: className, classId: classId),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: brandColor.withOpacity(0.12),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      color: brandColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          className,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color:
                                isDark ? Colors.white : const Color(0xFF1E2328),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          joinCode.isNotEmpty
                              ? 'Code: $joinCode'
                              : 'Class ID: $classId',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF6F7B87),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : const Color(0xFFF1F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.white70 : const Color(0xFF5C6670),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
              child: Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No classes joined",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ask your teacher for a 6-digit code",
              style: TextStyle(color: theme.hintColor, fontSize: 14),
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
        title: const Text(
          "Enter Class Code",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Ask your teacher for the 6-digit code to join their classroom.",
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _codeController,
              maxLength: 6,
              autofocus: true,
              style: const TextStyle(
                letterSpacing: 8,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor:
                    isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                hintText: "ABC123",
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                  letterSpacing: 2,
                  fontSize: 18,
                ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isJoining
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text("Join"),
          ),
        ],
      ),
    );
  }
}

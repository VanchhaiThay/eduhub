import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduhub/components/feature/classtap/class_detail/class_detail_page.dart';
import 'package:eduhub/utils/localization.dart';

class ClassTeacherTab extends StatefulWidget {
  final String language;
  const ClassTeacherTab({super.key, required this.language});

  @override
  State<ClassTeacherTab> createState() => _ClassTeacherTabState();
}

class _ClassTeacherTabState extends State<ClassTeacherTab> {
  final classNameController = TextEditingController();
  final searchController = TextEditingController(); // Controller for search
  String searchQuery = ""; // String to store search input
  bool isLoading = false;

  String? get uid => FirebaseAuth.instance.currentUser?.uid;
  final Color brandColor = const Color(0xFF38A39D);

  @override
  void dispose() {
    classNameController.dispose();
    searchController.dispose(); // Clean up
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
        "createdAt": FieldValue.serverTimestamp(),
        "studentCount": 0,
      });

      await FirebaseFirestore.instance
          .collection("class_lookup")
          .doc(joinCode)
          .set({"teacherId": uid, "classId": classRef.id, "className": name});

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

  Future<void> editClassName(
      String classId, String currentName, String joinCode) async {
    final editController = TextEditingController(text: currentName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Edit Class Name",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: editController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Class Name",
            hintText: "e.g. Science 101",
            filled: true,
            fillColor:
                isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final newName = editController.text.trim();
              if (newName.isEmpty) {
                _showStatus("Please enter a class name", isError: true);
                return;
              }

              Navigator.pop(context);

              try {
                // Update class name in user's classes collection
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(uid)
                    .collection("classes")
                    .doc(classId)
                    .update({"className": newName});

                // Also update class name in class_lookup collection for consistency
                await FirebaseFirestore.instance
                    .collection("class_lookup")
                    .doc(joinCode)
                    .update({"className": newName});

                _showStatus("Class name updated successfully!");
              } catch (e) {
                _showStatus("Failed to update class name", isError: true);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(Random().nextInt(chars.length)),
      ),
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

  Future<void> _copyClassCode(String code) async {
    try {
      await Clipboard.setData(ClipboardData(text: code));
      _showStatus("Class code copied: $code");
    } catch (e) {
      _showStatus("Failed to copy code", isError: true);
    }
  }

  // ================= UI COMPONENTS =================
  void showCreateDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "New Class",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: classNameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Class Name",
            hintText: "e.g. Science 101",
            filled: true,
            fillColor:
                isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: brandColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                'Please sign in to create classes',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showCreateDialog,
        backgroundColor: brandColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "New Class",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),

          // --- SEARCH FIELD SECTION ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: TextField(
                controller: searchController,
                onChanged: (val) {
                  setState(() {
                    searchQuery = val.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search your classes...",
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() => searchQuery = "");
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
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
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // Filter results based on search query
              final docs = snapshot.data?.docs ?? [];
              final filteredDocs = docs.where((doc) {
                final className =
                    (doc.data() as Map<String, dynamic>)['className']
                            ?.toString()
                            .toLowerCase() ??
                        "";
                return className.contains(searchQuery);
              }).toList();

              if (docs.isEmpty) return _buildEmptyState(theme);

              if (filteredDocs.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text("No matching classes found.")),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildClassCard(filteredDocs[index], theme, isDark),
                    childCount: filteredDocs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 70,
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
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildClassCard(DocumentSnapshot doc, ThemeData theme, bool isDark) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data["className"] ?? "Unnamed Class";
    final code = data["joinCode"] ?? "000000";
    final textColor = isDark ? Colors.white : Colors.grey.shade800;
    final subTextColor = isDark ? Colors.white60 : Colors.grey.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: Colors.white.withOpacity(0.08), width: 1)
            : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClassDetailPage(className: name, classId: doc.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        brandColor.withOpacity(0.15),
                        brandColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: brandColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Icon(Icons.tag_rounded, size: 14, color: brandColor),
                          const SizedBox(width: 4),
                          Text(
                            code,
                            style: TextStyle(
                              fontSize: 13,
                              color: brandColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _copyClassCode(code),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: brandColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: subTextColor),
                  onSelected: (val) {
                    if (val == 'edit') {
                      editClassName(doc.id, name, code);
                    } else if (val == 'delete') {
                      deleteClass(doc.id, code);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text("Edit Name"),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        "Delete",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
          Icon(
            Icons.library_books_rounded,
            size: 70,
            color: theme.hintColor.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text("No classes yet", style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

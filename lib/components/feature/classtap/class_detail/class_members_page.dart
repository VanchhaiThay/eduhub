import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'class_detail_constants.dart';

class ClassMembersPage extends StatefulWidget {
  final String classId;
  final String className;

  const ClassMembersPage({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<ClassMembersPage> createState() => _ClassMembersPageState();
}

class _ClassMembersPageState extends State<ClassMembersPage> {
  late final Future<String?> _teacherIdFuture;

  @override
  void initState() {
    super.initState();
    _teacherIdFuture = _resolveTeacherId();
  }

  Future<String?> _resolveTeacherId() async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid != null) {
      final ownClassDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUid)
          .collection('classes')
          .doc(widget.classId)
          .get();

      if (ownClassDoc.exists) {
        return currentUid;
      }
    }

    final lookupSnapshot = await FirebaseFirestore.instance
        .collection('class_lookup')
        .where('classId', isEqualTo: widget.classId)
        .limit(1)
        .get();

    if (lookupSnapshot.docs.isEmpty) {
      return null;
    }

    final data = lookupSnapshot.docs.first.data();
    return data['teacherId'] as String?;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _membersStream(String teacherId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(teacherId)
        .collection('classes')
        .doc(widget.classId)
        .collection('students')
        .orderBy('joinedAt', descending: false)
        .snapshots();
  }

  String _formatJoinedAt(dynamic joinedAt) {
    if (joinedAt is! Timestamp) {
      return 'Joined recently';
    }

    final date = joinedAt.toDate();
    final now = DateTime.now();
    final sameDay =
        now.year == date.year && now.month == date.month && now.day == date.day;

    if (sameDay) {
      return 'Joined today';
    }

    return 'Joined ${DateFormat('dd MMM yyyy').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = ClassDetailConstants.brandColor;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Members',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F1117),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<String?>(
        future: _teacherIdFuture,
        builder: (context, teacherSnapshot) {
          if (teacherSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final teacherId = teacherSnapshot.data;
          if (teacherId == null || teacherId.isEmpty) {
            return _StateCard(
              icon: Icons.group_off_rounded,
              title: 'Unable to load members',
              subtitle: 'We could not find this class member list.',
              isDark: isDark,
            );
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _membersStream(teacherId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _StateCard(
                  icon: Icons.error_outline_rounded,
                  title: 'Error loading members',
                  subtitle: 'Please try again in a moment.',
                  isDark: isDark,
                );
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return _StateCard(
                  icon: Icons.people_outline_rounded,
                  title: 'No members yet',
                  subtitle: 'Users who join this class will appear here.',
                  isDark: isDark,
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1D27) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        '${docs.length} ${docs.length == 1 ? 'member' : 'members'} joined',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF0F1117),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        final name = (data['name'] as String?)?.trim();
                        final displayName =
                            (name != null && name.isNotEmpty) ? name : 'Student';
                        final uid = (data['uid'] as String?) ?? '';
                        final initial = displayName[0].toUpperCase();

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1A1D27) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 21,
                                backgroundColor: brand.withValues(
                                  alpha: isDark ? 0.25 : 0.12,
                                ),
                                child: Text(
                                  initial,
                                  style: TextStyle(
                                    color: brand,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F1117),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      uid.isNotEmpty
                                          ? _formatJoinedAt(data['joinedAt'])
                                          : 'Joined member',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.55)
                                            : Colors.black.withValues(
                                                alpha: 0.45,
                                              ),
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  const _StateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1D27) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 34, color: ClassDetailConstants.brandColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F1117),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.55)
                      : Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

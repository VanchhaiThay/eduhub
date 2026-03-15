import 'dart:io'; // Add this
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Add this
import 'package:supabase_flutter/supabase_flutter.dart'; // Add this

class ClassDetailPage extends StatefulWidget {
  final String className;
  final String classId;

  const ClassDetailPage({
    super.key,
    required this.className,
    required this.classId,
  });

  @override
  State<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends State<ClassDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  bool _isUploading = false; // To show loading state during upload

  static const Color brandColor = Color(0xFF38A39D);
  static const Color accentColor = Color(0xFF2D817D);

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ================= LOGIC =================

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image == null) return;

    setState(() => _isUploading = true);

    try {
      final file = File(image.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${uid}.jpg';
      final path = 'chat_images/$fileName';

      // 1. Upload to Supabase Bucket 'photo_message'
      await Supabase.instance.client.storage
          .from('photo_message')
          .upload(path, file);

      // 2. Get Public URL
      final String imageUrl = Supabase.instance.client.storage
          .from('photo_message')
          .getPublicUrl(path);

      // 3. Send to Firestore
      await _saveMessageToFirestore(imageUrl: imageUrl);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || uid == null) return;
    _messageController.clear();
    await _saveMessageToFirestore(text: text);
  }

  Future<void> _saveMessageToFirestore({String? text, String? imageUrl}) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data();
      final senderName = "${userData?['firstName'] ?? ''} ${userData?['lastName'] ?? ''}".trim();

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('messages')
          .add({
        'senderId': uid,
        'senderName': senderName.isEmpty ? "User" : senderName,
        'message': text ?? "",
        'imageUrl': imageUrl, // Added image field
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      _scrollToBottom();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFB),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            if (_isUploading) const LinearProgressIndicator(color: brandColor, backgroundColor: Colors.transparent),
            Expanded(child: _buildMessageList()),
            _buildInputArea(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .doc(widget.classId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: brandColor));
        }
        final docs = snapshot.data?.docs ?? [];
        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildMessageBubble(data, data['senderId'] == uid);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data, bool isMe) {
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final timeStr = timestamp != null ? DateFormat('hh:mm a').format(timestamp) : '';
    final String? imageUrl = data['imageUrl'];
    final String message = data['message'] ?? "";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe) Text(data['senderName'] ?? "Student", style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isMe) _buildTimestamp(timeStr),
              Flexible(
                child: Container(
                  padding: imageUrl != null ? const EdgeInsets.all(4) : const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isMe ? brandColor : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.white),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(width: 200, height: 200, child: Center(child: CircularProgressIndicator()));
                            },
                          ),
                        ),
                      if (message.isNotEmpty)
                        Padding(
                          padding: imageUrl != null ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
                          child: Text(
                            message,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (!isMe) _buildTimestamp(timeStr),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Image Button
          IconButton(
            icon: const Icon(Icons.image_rounded, color: brandColor),
            onPressed: _pickAndUploadImage,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  hintText: "Write a message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildSendButton(),
        ],
      ),
    );
  }

  // Same _buildSendButton and _buildAppBar as your original code...
  // (Included from your snippet)
  Widget _buildSendButton() {
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [brandColor, accentColor])),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _sendMessage,
          customBorder: const CircleBorder(),
          child: const Padding(padding: EdgeInsets.all(12.0), child: Icon(Icons.send_rounded, color: Colors.white, size: 24)),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(widget.className),
      backgroundColor: brandColor,
    );
  }
  
  Widget _buildTimestamp(String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
    );
  }
}
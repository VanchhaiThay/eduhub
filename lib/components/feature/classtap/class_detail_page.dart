import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

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

  bool _isUploading = false;
  bool _isRecording = false;
  
  // Duration Logic
  int _recordDuration = 0;
  Timer? _timer;

  late AudioRecorder _audioRecorder;
  AudioPlayer? _audioPlayer;
  String? _currentlyPlayingUrl;

  static const Color brandColor = Color(0xFF38A39D);

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer?.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ================= LOGIC: TIMER =================

  void _startTimer() {
    _recordDuration = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ================= LOGIC: TEXT SENDING =================

  Future<void> _handleSendText() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    await _saveMessageToFirestore(text: text);
  }

  // ================= LOGIC: ACTIONS =================

  void _showActionSheet(String messageId, String currentText, bool isMe, bool hasImage) {
    if (!isMe) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hasImage)
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: brandColor),
                title: const Text('Edit Message'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(messageId, currentText);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete Message', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(messageId);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog(String messageId, String currentText) async {
    final TextEditingController editController = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Message"),
        content: TextField(controller: editController, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: brandColor),
            onPressed: () async {
              if (editController.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('classes')
                    .doc(widget.classId)
                    .collection('messages')
                    .doc(messageId)
                    .update({'message': editController.text.trim(), 'isEdited': true});
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String messageId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Message?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('classes')
                  .doc(widget.classId)
                  .collection('messages')
                  .doc(messageId)
                  .delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // ================= LOGIC: MEDIA =================

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$uid.jpg';
      final path = 'chat_images/$fileName';
      await Supabase.instance.client.storage.from('photo_message').upload(path, File(image.path));
      final String imageUrl = Supabase.instance.client.storage.from('photo_message').getPublicUrl(path);
      await _saveMessageToFirestore(imageUrl: imageUrl);
    } catch (e) {
      debugPrint("Upload Error: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _handleAudioRecording() async {
    if (_isRecording) {
      _timer?.cancel();
      int finalDuration = _recordDuration; 
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      
      if (path != null) {
        setState(() => _isUploading = true);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$uid.m4a';
        await Supabase.instance.client.storage.from('photo_message').upload('chat_audio/$fileName', File(path));
        final url = Supabase.instance.client.storage.from('photo_message').getPublicUrl('chat_audio/$fileName');
        
        await _saveMessageToFirestore(audioUrl: url, audioDuration: finalDuration);
        setState(() => _isUploading = false);
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        _startTimer();
        setState(() => _isRecording = true);
      }
    }
  }

  Future<void> _saveMessageToFirestore({String? text, String? imageUrl, String? audioUrl, int? audioDuration}) async {
    if (uid == null) return;
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final senderName = "${userDoc.data()?['firstName'] ?? ''} ${userDoc.data()?['lastName'] ?? ''}".trim();

      await FirebaseFirestore.instance.collection('classes').doc(widget.classId).collection('messages').add({
        'senderId': uid,
        'senderName': senderName.isEmpty ? "User" : senderName,
        'message': text ?? "",
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'audioDuration': audioDuration,
        'timestamp': FieldValue.serverTimestamp(),
        'isEdited': false,
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint("Firestore Error: $e");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0.0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  // ================= UI BUILDERS =================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7F8),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
        title: Text(widget.className, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18)),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          if (_isUploading) const LinearProgressIndicator(color: brandColor, backgroundColor: Colors.transparent),
          Expanded(child: _buildMessageList()),
          _buildInputArea(isDark),
        ],
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
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: brandColor));
        final docs = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final bool isMe = data['senderId'] == uid;
            return GestureDetector(
              onLongPress: () => _showActionSheet(doc.id, data['message'] ?? "", isMe, data['imageUrl'] != null),
              child: _buildMessageBubble(data, isMe),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> data, bool isMe) {
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final timeStr = timestamp != null ? DateFormat('HH:mm').format(timestamp) : '';
    final isEdited = data['isEdited'] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe) Padding(padding: const EdgeInsets.only(left: 4, bottom: 2), child: Text(data['senderName'] ?? "", style: const TextStyle(fontSize: 11, color: brandColor, fontWeight: FontWeight.bold))),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isMe) _buildTimeInfo(timeStr, isEdited, isMe),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? brandColor : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data['imageUrl'] != null) ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(data['imageUrl'])),
                      if (data['audioUrl'] != null) _buildAudioPlayer(data['audioUrl'], isMe, data['audioDuration']),
                      if (data['message'].toString().isNotEmpty) 
                        Text(
                          data['message'], 
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15)
                        ),
                    ],
                  ),
                ),
              ),
              if (!isMe) _buildTimeInfo(timeStr, isEdited, isMe),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioPlayer(String url, bool isMe, dynamic duration) {
    bool isPlaying = _currentlyPlayingUrl == url;
    // Handle duration if it comes back as int or double from Firestore
    int durationSecs = duration is int ? duration : (duration as num?)?.toInt() ?? 0;
    String displayTime = _formatDuration(durationSecs);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, color: isMe ? Colors.white : brandColor, size: 38),
          onPressed: () async {
            if (isPlaying) {
              await _audioPlayer?.pause();
              setState(() => _currentlyPlayingUrl = null);
            } else {
              await _audioPlayer?.play(UrlSource(url));
              setState(() => _currentlyPlayingUrl = url);
              _audioPlayer?.onPlayerComplete.listen((_) {
                if(mounted) setState(() => _currentlyPlayingUrl = null);
              });
            }
          },
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Voice Note", style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14, fontWeight: FontWeight.w600)),
            Text(displayTime, style: TextStyle(color: isMe ? Colors.white70 : Colors.black54, fontSize: 11)),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTimeInfo(String time, bool edited, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (edited) const Text("Edited", style: TextStyle(fontSize: 8, fontStyle: FontStyle.italic, color: Colors.grey)),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: isDark ? const Color(0xFF1F1F1F) : Colors.white,
      child: Row(
        children: [
          if (!_isRecording)
            IconButton(
              icon: const Icon(Icons.image_outlined, color: brandColor), 
              onPressed: _pickAndUploadImage
            ),
          Expanded(
            child: _isRecording 
              ? Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mic, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Recording... ${_formatDuration(_recordDuration)}",
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : TextField(
                  controller: _messageController,
                  maxLines: null,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Message...",
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
          ),
          const SizedBox(width: 4),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _messageController,
            builder: (context, value, child) {
              final bool hasText = value.text.trim().isNotEmpty;

              if (_isRecording) {
                return IconButton(
                  icon: const Icon(Icons.stop_circle, color: Colors.red, size: 32), 
                  onPressed: _handleAudioRecording
                );
              } else if (!hasText) {
                return IconButton(
                  icon: const Icon(Icons.mic_none, color: brandColor, size: 28), 
                  onPressed: _handleAudioRecording
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.send_rounded, color: brandColor, size: 28), 
                  onPressed: _handleSendText
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
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
import '../../../../utils/encryption_utils.dart';

class ClassDetailController extends ChangeNotifier {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final String classId;
  final String className;

  bool isUploading = false;
  bool isRecording = false;
  int recordDuration = 0;
  Timer? _timer;
  String? currentlyPlayingUrl;

  late AudioRecorder audioRecorder;
  AudioPlayer? audioPlayer;

  ClassDetailController({required this.classId, required this.className}) {
    audioRecorder = AudioRecorder();
    audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    audioRecorder.dispose();
    audioPlayer?.dispose();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ================= TIMER LOGIC =================

  void startTimer() {
    recordDuration = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      recordDuration++;
      notifyListeners();
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    recordDuration = 0;
    notifyListeners();
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ================= MESSAGE LOGIC =================

  Future<void> handleSendText() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messageController.clear();
    await saveMessageToFirestore(text: text);
  }

  Future<void> saveMessageToFirestore(
      {String? text,
      String? imageUrl,
      String? audioUrl,
      int? audioDuration}) async {
    if (uid == null) return;
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final senderName =
          "${userDoc.data()?['firstName'] ?? ''} ${userDoc.data()?['lastName'] ?? ''}"
              .trim();

      // Encrypt the message text before saving
      final encryptedMessage =
          text != null && text.isNotEmpty ? EncryptionUtils.encrypt(text) : "";

      await FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('messages')
          .add({
        'senderId': uid,
        'senderName': senderName.isEmpty ? "User" : senderName,
        'message': encryptedMessage,
        'imageUrl': imageUrl,
        'audioUrl': audioUrl,
        'audioDuration': audioDuration,
        'timestamp': FieldValue.serverTimestamp(),
        'isEdited': false,
      });
      scrollToBottom();
    } catch (e) {
      debugPrint("Firestore Error: $e");
    }
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  // ================= IMAGE LOGIC =================

  Future<void> pickAndUploadImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;

    String captionText = messageController.text.trim();
    bool shouldSend = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            final isDark =
                Theme.of(dialogContext).brightness == Brightness.dark;
            final media = MediaQuery.of(dialogContext);

            return Dialog(
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 380,
                  maxHeight: media.size.height * 0.8,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Preview Photo',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(image!.path),
                          height: media.size.height * 0.24,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: captionText,
                        maxLines: 2,
                        minLines: 1,
                        onChanged: (value) => captionText = value,
                        decoration: InputDecoration(
                          hintText: 'Add a message with this photo...',
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFF1F3F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancel'),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () async {
                              final replaced = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 85,
                              );
                              if (replaced != null && dialogContext.mounted) {
                                setStateDialog(() => image = replaced);
                              }
                            },
                            icon: const Icon(Icons.tune_rounded),
                            label: const Text('Edit Photo'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF38A39D),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              shouldSend = true;
                              Navigator.pop(dialogContext);
                            },
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    final caption = captionText.trim();
    if (!shouldSend || image == null) return;
    final XFile selectedImage = image!;

    isUploading = true;
    notifyListeners();

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$uid.jpg';
      final path = 'chat_images/$fileName';
      await Supabase.instance.client.storage
          .from('photo_message')
          .upload(path, File(selectedImage.path));
      final String imageUrl = Supabase.instance.client.storage
          .from('photo_message')
          .getPublicUrl(path);
      await saveMessageToFirestore(
        imageUrl: imageUrl,
        text: caption.isEmpty ? null : caption,
      );
      messageController.clear();
    } catch (e) {
      debugPrint("Upload Error: $e");
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  // ================= AUDIO RECORDING LOGIC =================

  Future<void> handleAudioRecording() async {
    if (isRecording) {
      _timer?.cancel();
      int finalDuration = recordDuration;
      final path = await audioRecorder.stop();
      isRecording = false;

      if (path != null) {
        isUploading = true;
        notifyListeners();

        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$uid.m4a';
        await Supabase.instance.client.storage
            .from('photo_message')
            .upload('chat_audio/$fileName', File(path));
        final url = Supabase.instance.client.storage
            .from('photo_message')
            .getPublicUrl('chat_audio/$fileName');

        await saveMessageToFirestore(
            audioUrl: url, audioDuration: finalDuration);
        isUploading = false;
        notifyListeners();
      }
    } else {
      if (await audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final path =
            '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await audioRecorder.start(const RecordConfig(), path: path);
        startTimer();
        isRecording = true;
        notifyListeners();
      }
    }
  }

  // ================= EDIT/DELETE LOGIC =================

  Future<void> updateMessage(String messageId, String newText) async {
    // Encrypt the updated message text
    final encryptedMessage = EncryptionUtils.encrypt(newText);
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .collection('messages')
        .doc(messageId)
        .update({'message': encryptedMessage, 'isEdited': true});
  }

  Future<void> deleteMessage(String messageId) async {
    await FirebaseFirestore.instance
        .collection('classes')
        .doc(classId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  // ================= AUDIO PLAYBACK =================

  Future<void> playAudio(String url) async {
    await audioPlayer?.play(UrlSource(url));
    currentlyPlayingUrl = url;
    notifyListeners();

    audioPlayer?.onPlayerComplete.listen((_) {
      currentlyPlayingUrl = null;
      notifyListeners();
    });
  }

  Future<void> pauseAudio() async {
    await audioPlayer?.pause();
    currentlyPlayingUrl = null;
    notifyListeners();
  }

  bool isPlayingUrl(String url) => currentlyPlayingUrl == url;

  void clearCurrentlyPlaying() {
    currentlyPlayingUrl = null;
    notifyListeners();
  }

  // ================= HELPERS =================

  bool isCurrentUser(String senderId) => senderId == uid;

  String formatMessageTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('HH:mm').format(timestamp.toDate());
  }
}

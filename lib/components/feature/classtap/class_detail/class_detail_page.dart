import 'package:flutter/material.dart';
import 'class_detail_constants.dart';
import 'class_detail_controller.dart';
import 'widgets/message_list_view.dart';
import 'widgets/message_input_bar.dart';
import 'widgets/message_action_sheet.dart';

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
  late ClassDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ClassDetailController(
      classId: widget.classId,
      className: widget.className,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showMessageAction(String messageId, String currentText, bool isMe, bool hasImage) {
    if (!isMe) return;

    MessageActionSheet.show(
      context,
      hasImage: hasImage,
      onEdit: () => _showEditDialog(messageId, currentText),
      onDelete: () => _showDeleteDialog(messageId),
    );
  }

  Future<void> _showEditDialog(String messageId, String currentText) async {
    final controller = TextEditingController(text: currentText);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Message"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ClassDetailConstants.brandColor),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _controller.updateMessage(messageId, result);
    }
  }

  Future<void> _showDeleteDialog(String messageId) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Message?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _controller.deleteMessage(messageId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ClassDetailConstants.darkBackground : ClassDetailConstants.lightBackground,
      appBar: AppBar(
        elevation: 1,
        backgroundColor: isDark ? ClassDetailConstants.darkSurface : Colors.white,
        title: Text(
          widget.className,
          style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isUploading) {
                return const LinearProgressIndicator(color: ClassDetailConstants.brandColor, backgroundColor: Colors.transparent);
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                return MessageListView(
                  classId: widget.classId,
                  scrollController: _controller.scrollController,
                  currentUserId: _controller.uid,
                  isPlayingUrl: _controller.isPlayingUrl,
                  onPlayAudio: _controller.playAudio,
                  onPauseAudio: _controller.pauseAudio,
                  onMessageAction: _showMessageAction,
                );
              },
            ),
          ),
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              return MessageInputBar(
                controller: _controller.messageController,
                isRecording: _controller.isRecording,
                recordDuration: _controller.recordDuration,
                formattedDuration: _controller.formatDuration(_controller.recordDuration),
                isDark: isDark,
                onPickImage: _controller.pickAndUploadImage,
                onRecordToggle: _controller.handleAudioRecording,
                onSendText: _controller.handleSendText,
              );
            },
          ),
        ],
      ),
    );
  }
}
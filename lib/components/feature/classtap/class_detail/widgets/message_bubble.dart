import 'package:flutter/material.dart';
import '../class_detail_constants.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMe;
  final bool isDark;
  final String timeStr;
  final bool isEdited;
  final Widget? audioPlayer;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.data,
    required this.isMe,
    required this.isDark,
    required this.timeStr,
    required this.isEdited,
    this.audioPlayer,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  data['senderName'] ?? "",
                  style: const TextStyle(fontSize: 11, color: ClassDetailConstants.brandColor, fontWeight: FontWeight.bold),
                ),
              ),
            Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isMe) _buildTimeInfo(),
                Flexible(child: _buildBubbleContent(context)),
                if (!isMe) _buildTimeInfo(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (isEdited)
            const Text("Edited", style: TextStyle(fontSize: 8, fontStyle: FontStyle.italic, color: Colors.grey)),
          Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBubbleContent(BuildContext context) {
    final textColor = isMe ? Colors.white : (isDark ? Colors.white : Colors.black87);
    final hasImage = data['imageUrl'] != null;
    final hasText = data['message'].toString().isNotEmpty;
    final hasAudio = audioPlayer != null;
    final isImageOnly = hasImage && !hasText && !hasAudio;
    final bubbleRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 0),
      bottomRight: Radius.circular(isMe ? 0 : 16),
    );

    return Container(
      padding: isImageOnly ? EdgeInsets.zero : const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isImageOnly
            ? Colors.transparent
            : (isMe ? ClassDetailConstants.brandColor : (isDark ? const Color(0xFF2C2C2C) : Colors.white)),
        borderRadius: bubbleRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            GestureDetector(
              onTap: () => _showFullScreenImage(context, data['imageUrl']),
              child: ClipRRect(
                borderRadius: isImageOnly ? bubbleRadius : BorderRadius.circular(8),
                child: Image.network(
                  data['imageUrl'],
                  width: 190,
                  height: 190,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (audioPlayer != null) audioPlayer!,
          if (data['message'].toString().isNotEmpty)
            Text(
              data['message'],
              style: TextStyle(color: textColor, fontSize: 15),
            ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    final isDialogDark = Theme.of(context).brightness == Brightness.dark;
    final closeIconColor = isDialogDark ? Colors.white : Colors.black87;
    final closeButtonColor = isDialogDark ? Colors.black45 : Colors.white70;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black87),
            ),
            Center(
              child: InteractiveViewer(
                child: Image.network(imageUrl),
              ),
            ),
            Positioned(
              top: 12,
              right: 16,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: closeButtonColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: closeIconColor, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../class_detail_constants.dart';

class AudioPlayerWidget extends StatelessWidget {
  final String url;
  final int duration;
  final bool isMe;
  final bool isDark;
  final bool isPlaying;
  final VoidCallback onPlayPause;

  const AudioPlayerWidget({
    super.key,
    required this.url,
    required this.duration,
    required this.isMe,
    required this.isDark,
    required this.isPlaying,
    required this.onPlayPause,
  });

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final displayTime = _formatDuration(duration);
    final textColor = isMe ? Colors.white : (isDark ? Colors.white : Colors.black87);
    final subtitleColor = isMe ? Colors.white70 : (isDark ? Colors.white70 : Colors.black54);
    final iconColor = isMe ? Colors.white : ClassDetailConstants.brandColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          icon: Icon(
            isPlaying ? Icons.pause_circle : Icons.play_circle,
            color: iconColor,
            size: 38,
          ),
          onPressed: onPlayPause,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Voice Note",
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              displayTime,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
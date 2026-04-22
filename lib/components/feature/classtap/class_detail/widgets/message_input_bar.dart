import 'package:flutter/material.dart';
import '../class_detail_constants.dart';

class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isRecording;
  final int recordDuration;
  final String formattedDuration;
  final bool isDark;
  final VoidCallback onPickImage;
  final VoidCallback onRecordToggle;
  final VoidCallback onSendText;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.isRecording,
    required this.recordDuration,
    required this.formattedDuration,
    required this.isDark,
    required this.onPickImage,
    required this.onRecordToggle,
    required this.onSendText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: isDark ? ClassDetailConstants.darkSurface : Colors.white,
      child: Row(
        children: [
          if (!isRecording)
            IconButton(
              icon: const Icon(Icons.image_outlined, color: ClassDetailConstants.brandColor),
              onPressed: onPickImage,
            ),
          Expanded(
            child: isRecording ? _buildRecordingState() : _buildTextField(isDark),
          ),
          const SizedBox(width: 4),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final bool hasText = value.text.trim().isNotEmpty;

              if (isRecording) {
                return IconButton(
                  icon: const Icon(Icons.stop_circle, color: Colors.red, size: 32),
                  onPressed: onRecordToggle,
                );
              } else if (!hasText) {
                return IconButton(
                  icon: const Icon(Icons.mic_none, color: ClassDetailConstants.brandColor, size: 28),
                  onPressed: onRecordToggle,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.send_rounded, color: ClassDetailConstants.brandColor, size: 28),
                  onPressed: onSendText,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingState() {
    return Container(
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
            "Recording... $formattedDuration",
            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(bool isDark) {
    return TextField(
      controller: controller,
      maxLines: null,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: "Message...",
        filled: true,
        fillColor: isDark ? ClassDetailConstants.darkInput : Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
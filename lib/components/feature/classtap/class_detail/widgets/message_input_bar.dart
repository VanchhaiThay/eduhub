import 'package:flutter/material.dart';
import '../class_detail_constants.dart';

class MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isRecording;
  final int recordDuration;
  final String formattedDuration;
  final bool isDark;
  final Future<void> Function(BuildContext context) onPickImage;
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
    final inputBackground = isDark ? ClassDetailConstants.darkSurface : Colors.white;
    final fieldBackground = isDark ? ClassDetailConstants.darkInput : const Color(0xFFF1F3F5);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: inputBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isRecording)
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined, color: ClassDetailConstants.brandColor),
              onPressed: () => onPickImage(context),
            ),
          Expanded(
            child: isRecording ? _buildRecordingState() : _buildTextField(isDark, fieldBackground),
          ),
          const SizedBox(width: 4),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final bool hasText = value.text.trim().isNotEmpty;

              if (isRecording) {
                return IconButton(
                  icon: const Icon(Icons.stop_circle_outlined, color: Colors.red, size: 31),
                  onPressed: onRecordToggle,
                );
              } else if (!hasText) {
                return IconButton(
                  icon: const Icon(Icons.mic_rounded, color: ClassDetailConstants.brandColor, size: 27),
                  onPressed: onRecordToggle,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded, color: ClassDetailConstants.brandColor, size: 28),
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

  Widget _buildTextField(bool isDark, Color fieldBackground) {
    return TextField(
      controller: controller,
      maxLines: null,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        hintText: "Message...",
        filled: true,
        fillColor: fieldBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFE5E8EC),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: ClassDetailConstants.brandColor,
            width: 1.2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
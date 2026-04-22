import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../class_detail_constants.dart';
import 'message_bubble.dart';
import 'audio_player_widget.dart';

class MessageListView extends StatelessWidget {
  final String classId;
  final ScrollController scrollController;
  final String? currentUserId;
  final bool Function(String) isPlayingUrl;
  final Future<void> Function(String) onPlayAudio;
  final Future<void> Function() onPauseAudio;
  final void Function(String messageId, String currentText, bool isMe, bool hasImage) onMessageAction;

  const MessageListView({
    super.key,
    required this.classId,
    required this.scrollController,
    required this.currentUserId,
    required this.isPlayingUrl,
    required this.onPlayAudio,
    required this.onPauseAudio,
    required this.onMessageAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .doc(classId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: ClassDetailConstants.brandColor));
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final bool isMe = data['senderId'] == currentUserId;
            final messageDate = _extractDate(data['timestamp']);
            final showDateSeparator = _shouldShowDateSeparator(docs, index, messageDate);

            return Column(
              children: [
                if (showDateSeparator && messageDate != null)
                  _DateSeparator(
                    label: _formatDateLabel(messageDate),
                    isDark: isDark,
                  ),
                MessageBubble(
                  data: data,
                  isMe: isMe,
                  isDark: isDark,
                  timeStr: _formatTime(data['timestamp']),
                  isEdited: data['isEdited'] ?? false,
                  audioPlayer: data['audioUrl'] != null
                      ? AudioPlayerWidget(
                          url: data['audioUrl'],
                          duration: _parseDuration(data['audioDuration']),
                          isMe: isMe,
                          isDark: isDark,
                          isPlaying: isPlayingUrl(data['audioUrl']),
                          onPlayPause: () {
                            if (isPlayingUrl(data['audioUrl'])) {
                              onPauseAudio();
                            } else {
                              onPlayAudio(data['audioUrl']);
                            }
                          },
                        )
                      : null,
                  onLongPress: () => onMessageAction(
                    doc.id,
                    data['message'] ?? "",
                    isMe,
                    data['imageUrl'] != null,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final ts = timestamp as Timestamp;
    return '${ts.toDate().hour.toString().padLeft(2, '0')}:${ts.toDate().minute.toString().padLeft(2, '0')}';
  }

  int _parseDuration(dynamic duration) {
    if (duration is int) return duration;
    if (duration == null) return 0;
    return (duration as num).toInt();
  }

  DateTime? _extractDate(dynamic timestamp) {
    if (timestamp is! Timestamp) return null;
    final date = timestamp.toDate();
    return DateTime(date.year, date.month, date.day);
  }

  bool _shouldShowDateSeparator(List<QueryDocumentSnapshot> docs, int index, DateTime? currentDate) {
    if (currentDate == null) return false;
    if (index + 1 >= docs.length) return true;

    final nextData = docs[index + 1].data() as Map<String, dynamic>;
    final olderDate = _extractDate(nextData['timestamp']);
    if (olderDate == null) return true;

    return !_isSameDate(currentDate, olderDate);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (_isSameDate(date, today)) return 'Today';
    if (_isSameDate(date, yesterday)) return 'Yesterday';
    return DateFormat('EEEE, MMM d, y').format(date);
  }
}

class _DateSeparator extends StatelessWidget {
  final String label;
  final bool isDark;

  const _DateSeparator({
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? Colors.white10 : Colors.black12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

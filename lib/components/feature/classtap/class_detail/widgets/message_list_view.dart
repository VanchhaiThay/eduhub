import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../class_detail_constants.dart';
import 'message_bubble.dart';
import 'audio_player_widget.dart';

class MessageListView extends StatefulWidget {
  final String classId;
  final ScrollController scrollController;
  final String? currentUserId;
  final bool Function(String) isPlayingUrl;
  final Future<void> Function(String) onPlayAudio;
  final Future<void> Function() onPauseAudio;
  final void Function(
    String messageId,
    String currentText,
    bool isMe,
    bool hasImage,
    String? imageUrl,
  ) onMessageAction;

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
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  bool showScrollToBottomButton = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    // ListView is reversed, so latest messages are near minScrollExtent (usually 0).
    final isAwayFromLatest = _scrollController.position.pixels > 100;
    if (isAwayFromLatest != showScrollToBottomButton) {
      setState(() => showScrollToBottomButton = isAwayFromLatest);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('classes')
              .doc(widget.classId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: ClassDetailConstants.brandColor,
                  strokeWidth: 2.5,
                ),
              );
            }

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No messages yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a conversation!',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              reverse: true,
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final bool isMe = data['senderId'] == widget.currentUserId;
                final messageDate = _extractDate(data['timestamp']);
                final showDateSeparator = _shouldShowDateSeparator(
                  docs,
                  index,
                  messageDate,
                );

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
                              isPlaying: widget.isPlayingUrl(data['audioUrl']),
                              onPlayPause: () {
                                if (widget.isPlayingUrl(data['audioUrl'])) {
                                  widget.onPauseAudio();
                                } else {
                                  widget.onPlayAudio(data['audioUrl']);
                                }
                              },
                            )
                          : null,
                      onLongPress: () => widget.onMessageAction(
                        doc.id,
                        data['message'] ?? "",
                        isMe,
                        data['imageUrl'] != null,
                        data['imageUrl']?.toString(),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        Positioned(
          right: 16,
          bottom: 18,
          child: SafeArea(
            minimum: const EdgeInsets.only(bottom: 56),
            child: AnimatedScale(
              scale: showScrollToBottomButton ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: IgnorePointer(
                ignoring: !showScrollToBottomButton,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _scrollToBottom,
                    borderRadius: BorderRadius.circular(24),
                    child: Ink(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ClassDetailConstants.brandColor,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_downward_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final ts = timestamp as Timestamp;
    final date = ts.toDate();
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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

  bool _shouldShowDateSeparator(
    List<QueryDocumentSnapshot> docs,
    int index,
    DateTime? currentDate,
  ) {
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
    return DateFormat('MMM d, yyyy').format(date);
  }
}

class _DateSeparator extends StatelessWidget {
  final String label;
  final bool isDark;

  const _DateSeparator({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}

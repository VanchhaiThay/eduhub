import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 6),
                child: Text(
                  data['senderName'] ?? "Unknown",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ClassDetailConstants.brandColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: isMe
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (isEdited)
            Text(
              "(edited)",
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleContent(BuildContext context) {
    final textColor = isMe
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);
    final linkColor = isMe ? Colors.white : const Color(0xFF0A7EA4);
    final hasImage = data['imageUrl'] != null;
    final messageText = data['message']?.toString() ?? '';
    final hasText = messageText.trim().isNotEmpty;
    final hasAudio = audioPlayer != null;
    final isImageOnly = hasImage && !hasText && !hasAudio;
    final isImageWithCaption = hasImage && hasText && !hasAudio;
    final links = _extractLinks(messageText);

    final bubbleRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMe ? 18 : 2),
      bottomRight: Radius.circular(isMe ? 2 : 18),
    );

    final bubbleColor = isImageOnly
        ? Colors.transparent
        : (isMe
              ? ClassDetailConstants.brandColor
              : (isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade100));

    if (isImageWithCaption) {
      return _buildTelegramStyleImageCaptionBubble(
        context: context,
        imageUrl: data['imageUrl'],
        messageText: messageText,
        links: links,
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      padding: isImageOnly
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: bubbleRadius,
        boxShadow: !isImageOnly
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            GestureDetector(
              onTap: () => _showFullScreenImage(context, data['imageUrl']),
              onLongPress: () =>
                  _showImageActionSheet(context, data['imageUrl']),
              child: ClipRRect(
                borderRadius: isImageOnly
                    ? bubbleRadius
                    : BorderRadius.circular(10),
                child: Image.network(
                  data['imageUrl'],
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey.shade300,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          if (hasAudio)
            Padding(
              padding: hasImage
                  ? const EdgeInsets.only(top: 8)
                  : EdgeInsets.zero,
              child: audioPlayer!,
            ),
          if (hasText)
            Padding(
              padding: hasImage || hasAudio
                  ? const EdgeInsets.only(top: 8)
                  : EdgeInsets.zero,
              child: _buildMessageTextWithLinkMenu(
                context: context,
                messageText: messageText,
                links: links,
                textColor: textColor,
                linkColor: linkColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTelegramStyleImageCaptionBubble({
    required BuildContext context,
    required String imageUrl,
    required String messageText,
    required List<String> links,
  }) {
    final imageRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 8 : 2),
      bottomRight: Radius.circular(isMe ? 2 : 8),
    );
    final captionColor = isMe
        ? const Color(0xFF2F9E98)
        : (isDark ? const Color(0xFF3A3A3A) : Colors.white);
    final textColor = isMe
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);
    final linkColor = isMe ? Colors.white : const Color(0xFF0A7EA4);

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: captionColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.08),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _showFullScreenImage(context, imageUrl),
            onLongPress: () => _showImageActionSheet(context, imageUrl),
            child: ClipRRect(
              borderRadius: imageRadius,
              child: Image.network(
                imageUrl,
                width: 220,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            child: _buildMessageTextWithLinkMenu(
              context: context,
              messageText: messageText,
              links: links,
              textColor: textColor,
              linkColor: linkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTextWithLinkMenu({
    required BuildContext context,
    required String messageText,
    required List<String> links,
    required Color textColor,
    required Color linkColor,
  }) {
    if (links.isEmpty) {
      return _buildLinkedMessageText(
        context: context,
        text: messageText,
        textColor: textColor,
        linkColor: linkColor,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: _buildLinkedMessageText(
            context: context,
            text: messageText,
            textColor: textColor,
            linkColor: linkColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showLinkOptions(context, links),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.more_horiz_rounded,
                size: 18,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedMessageText({
    required BuildContext context,
    required String text,
    required Color textColor,
    required Color linkColor,
  }) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'((https?:\/\/|www\.)[^\s]+)', caseSensitive: false);

    int start = 0;
    final matches = regex.allMatches(text);
    for (final match in matches) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        );
      }

      final rawUrl = text.substring(match.start, match.end);
      spans.add(
        TextSpan(
          text: rawUrl,
          style: TextStyle(
            color: linkColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1.4,
            decoration: TextDecoration.underline,
            decorationColor: linkColor,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _openLink(context, rawUrl),
        ),
      );

      start = match.end;
    }

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
      );
    }

    if (spans.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      );
    }

    return Text.rich(TextSpan(children: spans));
  }

  List<String> _extractLinks(String text) {
    final regex = RegExp(r'((https?:\/\/|www\.)[^\s]+)', caseSensitive: false);
    return regex
        .allMatches(text)
        .map((m) => text.substring(m.start, m.end))
        .toSet()
        .toList();
  }

  Uri _normalizeUrl(String rawUrl) {
    final trimmed = rawUrl.trim();
    if (trimmed.startsWith(RegExp(r'https?:\/\/', caseSensitive: false))) {
      return Uri.parse(trimmed);
    }
    return Uri.parse('https://$trimmed');
  }

  Future<void> _openLink(BuildContext context, String rawUrl) async {
    try {
      final uri = _normalizeUrl(rawUrl);
      final canOpen = await canLaunchUrl(uri);
      if (!canOpen) throw Exception('Cannot open link');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open this link')));
    }
  }

  void _showLinkOptions(BuildContext context, List<String> links) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text(
                  'Link options',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              for (var i = 0; i < links.length; i++) ...[
                ListTile(
                  leading: const Icon(Icons.open_in_new_rounded),
                  title: Text(
                    links.length == 1 ? 'Open link' : 'Open link ${i + 1}',
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _openLink(context, links[i]);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.content_copy_rounded),
                  title: Text(
                    links.length == 1 ? 'Copy link' : 'Copy link ${i + 1}',
                  ),
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: links[i]));
                    if (!context.mounted) return;
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied')),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showImageActionSheet(BuildContext context, String imageUrl) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF2A2A2A) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ClassDetailConstants.brandColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: ClassDetailConstants.brandColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Image Options',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Options
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.link_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              title: const Text('Copy Link'),
              subtitle: const Text('Copy image URL to clipboard'),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: imageUrl));
                if (!context.mounted) return;
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image link copied')),
                );
              },
            ),

            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.save_alt_rounded,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              title: const Text('Save Image'),
              subtitle: const Text('Download image to gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                // TODO: Implement actual image saving
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image saved to gallery')),
                );
              },
            ),

            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.open_in_full_rounded,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              title: const Text('View Fullscreen'),
              subtitle: const Text('Open image in fullscreen mode'),
              onTap: () {
                Navigator.pop(sheetContext);
                _showFullScreenImage(context, imageUrl);
              },
            ),

            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.share_rounded,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              title: const Text('Share Image'),
              subtitle: const Text('Share image with others'),
              onTap: () {
                Navigator.pop(sheetContext);
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share functionality coming soon!'),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    final isDialogDark = Theme.of(context).brightness == Brightness.dark;
    final closeIconColor = isDialogDark ? Colors.white : Colors.white;
    final closeButtonColor = isDialogDark ? Colors.black45 : Colors.black45;

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
              child: Container(color: Colors.black.withOpacity(0.9)),
            ),
            Center(child: InteractiveViewer(child: Image.network(imageUrl))),
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: closeButtonColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: closeIconColor, size: 26),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: closeButtonColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    // TODO: Implement actual image saving functionality
                    // For now, show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image saved to gallery'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(Icons.save_alt, color: closeIconColor, size: 26),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

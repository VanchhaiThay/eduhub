import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../class_detail_constants.dart';

class MessageActionSheet extends StatelessWidget {
  final bool hasImage;
  final bool isDark;
  final String? imageUrl;
  final String classId;
  final String messageId;
  final String messageText;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onViewImage;

  const MessageActionSheet({
    super.key,
    required this.hasImage,
    required this.isDark,
    required this.imageUrl,
    required this.classId,
    required this.messageId,
    required this.messageText,
    required this.onEdit,
    required this.onDelete,
    this.onViewImage,
  });

  static void show(
    BuildContext context, {
    required bool hasImage,
    String? imageUrl,
    required String classId,
    required String messageId,
    required String messageText,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
    VoidCallback? onViewImage,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? ClassDetailConstants.darkSurface : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MessageActionSheet(
        hasImage: hasImage,
        isDark: isDark,
        imageUrl: imageUrl,
        classId: classId,
        messageId: messageId,
        messageText: messageText,
        onEdit: onEdit,
        onDelete: onDelete,
        onViewImage: onViewImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasImage && imageUrl != null)
            ListTile(
              leading: const Icon(
                Icons.open_in_full_rounded,
                color: ClassDetailConstants.brandColor,
              ),
              title: Text(
                'View Image',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                onViewImage?.call();
              },
            ),
          if (hasImage && imageUrl != null)
            ListTile(
              leading: const Icon(
                Icons.link_rounded,
                color: ClassDetailConstants.brandColor,
              ),
              title: Text(
                'Copy Image Link',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              onTap: () async {
                // Create deep link URL using custom scheme to avoid 404 errors
                final Uri deepLinkUri = Uri.parse('eduhub://image').replace(
                  queryParameters: {'classId': classId, 'imageUrl': imageUrl!},
                );
                await Clipboard.setData(
                  ClipboardData(text: deepLinkUri.toString()),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image link copied')),
                );
              },
            ),
          if (hasImage && messageText.trim().isNotEmpty)
            ListTile(
              leading: const Icon(
                Icons.content_copy_rounded,
                color: ClassDetailConstants.brandColor,
              ),
              title: Text(
                'Copy Caption',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              onTap: () async {
                await Clipboard.setData(
                  ClipboardData(text: messageText.trim()),
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Caption copied')));
              },
            ),
          if (!hasImage)
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: ClassDetailConstants.brandColor,
              ),
              title: Text(
                'Edit Message',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text(
              'Delete Message',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class EditMessageDialog extends StatelessWidget {
  final String messageId;
  final String currentText;
  final Future<void> Function(String) onSave;

  const EditMessageDialog({
    super.key,
    required this.messageId,
    required this.currentText,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required String messageId,
    required String currentText,
    required Future<void> Function(String) onSave,
  }) {
    final controller = TextEditingController(text: currentText);
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Message"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ClassDetailConstants.brandColor,
            ),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await onSave(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class DeleteConfirmDialog extends StatelessWidget {
  final String messageId;
  final Future<void> Function(String) onDelete;

  const DeleteConfirmDialog({
    super.key,
    required this.messageId,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required String messageId,
    required Future<void> Function(String) onDelete,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Message?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await onDelete(messageId);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

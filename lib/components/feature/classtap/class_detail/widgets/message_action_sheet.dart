import 'package:flutter/material.dart';
import '../class_detail_constants.dart';

class MessageActionSheet extends StatelessWidget {
  final bool hasImage;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MessageActionSheet({
    super.key,
    required this.hasImage,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  static void show(
    BuildContext context, {
    required bool hasImage,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? ClassDetailConstants.darkSurface : null,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => MessageActionSheet(
        hasImage: hasImage,
        isDark: isDark,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hasImage)
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: ClassDetailConstants.brandColor),
              title: Text('Edit Message', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text('Delete Message', style: TextStyle(color: Colors.redAccent)),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ClassDetailConstants.brandColor),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await onDelete(messageId);
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
    return const SizedBox.shrink();
  }
}
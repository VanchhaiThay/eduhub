import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String?) onImageUrlChanged;
  final VoidCallback? onUploadStarted;
  final VoidCallback? onUploadFinished;

  const ProfileImagePicker({
    super.key,
    this.initialImageUrl,
    required this.onImageUrlChanged,
    this.onUploadStarted,
    this.onUploadFinished,
  });

  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  String? _profileImageUrl;
  bool _isUploading = false;
  final auth.User? _currentUser = auth.FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _profileImageUrl = widget.initialImageUrl;
  }

  Future<void> _showImageSourceSheet() async {
    if (_isUploading) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Change profile photo",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera_outlined,
                  color: Colors.tealAccent,
                ),
                title: const Text("Take a photo"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Colors.tealAccent,
                ),
                title: const Text("Choose from gallery"),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              if (_profileImageUrl != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    "Remove current photo",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _removeProfileImage();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _removeProfileImage() async {
    try {
      await _currentUser?.updatePhotoURL(null);
      if (mounted) {
        setState(() => _profileImageUrl = null);
        widget.onImageUrlChanged(null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile photo removed."),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      debugPrint("Remove photo failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not remove photo: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 800,
    );

    if (image == null) return;

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No internet connection. Please check your network."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isUploading = true);
    widget.onUploadStarted?.call();

    const maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final file = File(image.path);
        final String userId = _currentUser?.uid ?? 'anon';
        final String fileName =
            '$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await Supabase.instance.client.storage
            .from('eduhub_user_profile')
            .upload(
              fileName,
              file,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );

        final String publicUrl = Supabase.instance.client.storage
            .from('eduhub_user_profile')
            .getPublicUrl(fileName);

        await _currentUser?.updatePhotoURL(publicUrl);

        setState(() {
          _profileImageUrl = publicUrl;
          _isUploading = false;
        });
        widget.onImageUrlChanged(publicUrl);
        widget.onUploadFinished?.call();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile image updated successfully!"),
              backgroundColor: Colors.teal,
            ),
          );
        }
        return;
      } catch (e) {
        debugPrint("Upload attempt $attempt/$maxRetries failed: $e");
        if (attempt < maxRetries) {
          final delay = Duration(seconds: attempt * 2);
          await Future.delayed(delay);
        }
      }
    }

    setState(() => _isUploading = false);
    widget.onUploadFinished?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Upload failed after 3 retries. Check internet and try again.",
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget provides the GestureDetector for tapping to show sheet
    // Avatar UI is in profile_header.dart, but picker logic here
    return GestureDetector(
      onTap: _isUploading ? null : _showImageSourceSheet,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(blurRadius: 10, color: Colors.black12, spreadRadius: 2),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.blue.shade50,
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!)
                  : null,
              child: _profileImageUrl == null
                  ? Container() // Initials in header
                  : null,
            ),
            if (_isUploading)
              const CircularProgressIndicator(color: Colors.tealAccent),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.tealAccent,
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

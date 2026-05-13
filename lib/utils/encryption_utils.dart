import 'dart:convert';

class EncryptionUtils {
  static const String _encryptionKey =
      'EduHubSecureKey2024!@#ChatEncryption'; // In production, store this securely

  static String encrypt(String plainText) {
    if (plainText.isEmpty) return plainText;

    try {
      // Generate a simple XOR-based encryption for demonstration
      // In production, use proper encryption like AES
      final bytes = utf8.encode(plainText);
      final keyBytes = utf8.encode(_encryptionKey);

      final encryptedBytes = <int>[];
      for (int i = 0; i < bytes.length; i++) {
        encryptedBytes.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      // Convert to base64 for safe storage in Firestore
      return base64.encode(encryptedBytes);
    } catch (e) {
      // Return original text if encryption fails
      return plainText;
    }
  }

  static String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return encryptedText;

    try {
      // Check if text is base64 encoded (encrypted)
      if (!_isBase64(encryptedText)) {
        return encryptedText; // Return as-is if not encrypted
      }

      final encryptedBytes = base64.decode(encryptedText);
      final keyBytes = utf8.encode(_encryptionKey);

      final decryptedBytes = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decryptedBytes);
    } catch (e) {
      // Return original text if decryption fails
      return encryptedText;
    }
  }

  static bool _isBase64(String str) {
    try {
      base64.decode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Method to check if a message is already encrypted
  static bool isEncrypted(String text) {
    if (text.isEmpty) return false;
    return _isBase64(text);
  }
}

import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class CryptoUtil {
  static final algorithm = AesGcm.with256bits();

  static Future<SecretKey> _deriveKey(String roomCode) async {
    final bytes = utf8.encode(roomCode.padRight(32, '0')).sublist(0, 32);
    return SecretKey(bytes);
  }

  static Future<String> encrypt(String text, String roomCode) async {
    final secretKey = await _deriveKey(roomCode);
    final clearText = utf8.encode(text);

    final secretBox = await algorithm.encrypt(clearText, secretKey: secretKey);

    return base64.encode(secretBox.concatenation());
  }

  static Future<String> decrypt(String encodedData, String roomCode) async {
    try {
      final secretKey = await _deriveKey(roomCode);
      final combinedBytes = base64.decode(encodedData);

      final secretBox = SecretBox.fromConcatenation(
        combinedBytes,
        nonceLength: algorithm.nonceLength,
        macLength: algorithm.macAlgorithm.macLength,
      );

      final clearText = await algorithm.decrypt(
        secretBox,
        secretKey: secretKey,
      );

      return utf8.decode(clearText);
    } catch (e) {
      return "[Mensagem indecifrável]";
    }
  }
}

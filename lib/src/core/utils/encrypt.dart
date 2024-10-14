import 'package:computer/computer.dart';
import 'package:encrypt/encrypt.dart';

/// AES encryption utils.
abstract final class AesUtils {
  /// - [str] is the key to encrypt the data. Not base64 encoded.
  static Encrypter getEncrypter(String str) {
    final key = Key.fromUtf8(str);
    return Encrypter(AES(key));
  }

  static IV get newIv => IV.fromLength(16);

  /// - [key] is the key to encrypt the data. Not base64 encoded.
  /// - [data] is the data to encrypt. Not base64 encoded.
  static Future<Encrypted> encryptStr(String key, String data) {
    return Computer.shared.startNoParam(() {
      final encrypter = getEncrypter(key);
      final iv = newIv;
      return encrypter.encrypt(data, iv: iv);
    });
  }

  /// - [key] is the key to decrypt the data. Not base64 encoded.
  /// - [b64] is the data to decrypt.
  static Future<String> decryptB64(String key, String b64) {
    return Computer.shared.startNoParam(() {
      final encrypter = getEncrypter(key);
      final data = Encrypted.fromBase64(b64);
      return encrypter.decrypt(data);
    });
  }
}

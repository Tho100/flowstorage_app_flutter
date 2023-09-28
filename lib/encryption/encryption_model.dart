import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class EncryptionClass {

  late Encrypter _encrypter;
  late Key _key;
  late IV _iv;

  EncryptionClass() {
    _key = Key(Uint8List.fromList(utf8.encode("0123456789085746")));
    _iv = IV.fromLength(16);
    _encrypter = Encrypter(AES(_key, mode: AESMode.cbc, padding: 'PKCS7'));
  }

  String encrypt(String? plainText) {

    try {

      final encrypted = _encrypter.encrypt(plainText!, iv: _iv);
      return base64.encode(encrypted.bytes);

    } catch (err) {
      return "";
    }

  }

  String decrypt(String? encryptedText) {

    try {

      final decrypted = _encrypter.decrypt(Encrypted(base64.decode(encryptedText!)), iv: _iv);
      return decrypted;

    } catch (err) {
      return "";
    }

  }
}

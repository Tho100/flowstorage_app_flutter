import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class EncryptionClass {

  late Encrypter _encrypter;
  late Key _key;
  late IV _iv;

  EncryptionClass() {
    _key = Key.fromUtf8("Rw2345_789qTz345");
    _iv = IV.fromUtf8("Rw2345_789qTz345"); 
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

      final decodeBytes = base64.decode(encryptedText!);      
      final decryptedString = _encrypter.decrypt(Encrypted(decodeBytes), iv: _iv);

      return decryptedString;

    } catch (err) {
      return "";
    }

  }
}
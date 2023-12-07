import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthModel {

  String computeAuth(String inputStr) {
    List<int> authByteCase = utf8.encode(inputStr);
    final authHashCase = sha256.convert(authByteCase);
    final strAuthCase = authHashCase.toString().toUpperCase();
    return strAuthCase;
  }

}
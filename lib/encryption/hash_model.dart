import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthModel {

  String computeAuth(String inputStr) {

    final authByteCase = utf8.encode(inputStr);
    final authHashCase = sha256.convert(authByteCase);
    
    return authHashCase.toString().toUpperCase();

  }

}
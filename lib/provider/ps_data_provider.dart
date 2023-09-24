import 'package:flutter/material.dart';

class PsUploadDataProvider extends ChangeNotifier {
  
  String _psTitleValue = '';
  String _psCommentValue = '';
  String _psTagValue = '';

  String get psCommentValue => _psCommentValue;
  String get psTagValue => _psTagValue;
  String get psTitleValue => _psTitleValue;

  void setCommentValue(String value) {
    _psCommentValue = value;
    notifyListeners();
  }

  void setTitleValue(String value) {
    _psTitleValue = value;
    notifyListeners();
  }

  void setTagValue(String value) {
    _psTagValue = value;
    notifyListeners();
  }

}
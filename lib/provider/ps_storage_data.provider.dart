import 'dart:typed_data';

import 'package:flutter/material.dart';

class PsStorageDataProvider extends ChangeNotifier {

  final List<String> _psUploaderList = <String>[];
  final List<String> _psTagsList = <String>[];
  final List<Color> _psTagsColorList = <Color>[];
  final List<String> _psTitleList = <String>[];
  
  List<String> _psSearchNameList = [];
  List<String> _psSearchImageBytesList = [];
  
  List<Uint8List> _psImageBytesList = <Uint8List>[];
  List<Uint8List> _psThumbnailBytesList = <Uint8List>[];

  List<Uint8List> _myPsImageBytesList = <Uint8List>[];
  List<Uint8List> _myPsThumbnailBytesList = <Uint8List>[];

  List<Uint8List> get psImageBytesList => _psImageBytesList;
  List<Uint8List> get psThumbnailBytesList => _psThumbnailBytesList;

  List<Uint8List> get myPsImageBytesList => _myPsImageBytesList;
  List<Uint8List> get myPsThumbnailBytesList => _myPsThumbnailBytesList;
  
  List<String> get psUploaderList => _psUploaderList;
  List<String> get psTagsList => _psTagsList;
  List<Color> get psTagsColorList => _psTagsColorList;
  List<String> get psTitleList => _psTitleList;

  List<String> get psSearchNameList => _psSearchNameList;
  List<String> get psSearchImageBytesList => _psSearchImageBytesList;

  void setPsSearcName(List<String> name) {
    _psSearchNameList = name;
    notifyListeners();
  }

  void setPsSearchImageBytes(List<String> base64) {
    _psSearchImageBytesList = base64;
    notifyListeners();
  }

  void setPsImageBytes(List<Uint8List> bytes) {
    _psImageBytesList = bytes;
    notifyListeners();
  }

  void setPsThumbnailBytes(List<Uint8List> bytes) {
    _psThumbnailBytesList = bytes;
    notifyListeners();
  }

  void setMyPsImageBytes(List<Uint8List> bytes) {
    _myPsImageBytesList = bytes;
    notifyListeners();
  }

  void setMyPsThumbnailBytes(List<Uint8List> bytes) {
    _myPsThumbnailBytesList = bytes;
    notifyListeners();
  }

}
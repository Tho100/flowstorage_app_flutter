import 'dart:typed_data';

import 'package:flutter/material.dart';

class PsStorageDataProvider extends ChangeNotifier {

  final List<String> _psUploaderList = <String>[];
  final List<String> _psTagsList = <String>[];
  final List<Color> _psTagsColorList = <Color>[];
  final List<String> _psTitleList = <String>[];
  
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
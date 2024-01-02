import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flutter/material.dart';

class TempDataProvider extends ChangeNotifier {
  
  OriginFile _origin = OriginFile.home;

  Uint8List _fileByteData = Uint8List(0);

  String _folderTitleValue = '';
  String _directoryTitleValue = '';
  String _selectedFileName = '';
  String _appBarTitle = '';

  int _psTotalUpload = 0;

  OriginFile get origin => _origin;

  Uint8List get fileByteData => _fileByteData;

  String get folderName => _folderTitleValue;
  String get directoryName => _directoryTitleValue;
  String get selectedFileName => _selectedFileName;
  String get appBarTitle => _appBarTitle;

  int get psTotalUpload => _psTotalUpload;

  void clearFileData() {
    _fileByteData = Uint8List(0);
  }

  void addPsTotalUpload() {
    _psTotalUpload++;
    notifyListeners();
  }

  void setPsTotalUpload(int value) {
    _psTotalUpload = value;
  }

  void setFileData(Uint8List byteData) {
    _fileByteData = byteData;
  }

  void setOrigin(OriginFile value) {
    _origin = value;
  }

  void setAppBarTitle(String value) {
    _appBarTitle = value;
    notifyListeners();
  }

  void setCurrentFolder(String value) {
    _folderTitleValue = value;
    notifyListeners();
  }

  void setCurrentDirectory(String value) {
    _directoryTitleValue = value;
    notifyListeners();
  }

  void setCurrentFileName(String value) {
    _selectedFileName = value;
    notifyListeners();
  }

}
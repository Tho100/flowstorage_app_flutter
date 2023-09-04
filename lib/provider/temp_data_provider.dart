import 'package:flutter/material.dart';

class TempDataProvider extends ChangeNotifier {
  
  String _fileOrigin = '';
  String _folderTitleValue = '';
  String _directoryTitleValue = '';
  String _selectedFileName = '';
  String _appBarTitle = '';

  String get fileOrigin => _fileOrigin;
  String get folderName => _folderTitleValue;
  String get directoryName => _directoryTitleValue;
  String get selectedFileName => _selectedFileName;
  String get appBarTitle => _appBarTitle;

  void setAppBarTitle(String value) {
    _appBarTitle = value;
    notifyListeners();
  }

  void setOrigin(String value) {
    _fileOrigin = value;
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
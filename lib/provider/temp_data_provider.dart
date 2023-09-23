import 'package:flowstorage_fsc/constant.dart';
import 'package:flutter/material.dart';

class TempDataProvider extends ChangeNotifier {
  
  OriginFile _origin = OriginFile.home;

  String _folderTitleValue = '';
  String _directoryTitleValue = '';
  String _selectedFileName = '';
  String _appBarTitle = '';

  OriginFile get origin => _origin;

  String get folderName => _folderTitleValue;
  String get directoryName => _directoryTitleValue;
  String get selectedFileName => _selectedFileName;
  String get appBarTitle => _appBarTitle;

  void setAppBarTitle(String value) {
    _appBarTitle = value;
    notifyListeners();
  }

  void setOrigin(OriginFile value) {
    _origin = value;
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
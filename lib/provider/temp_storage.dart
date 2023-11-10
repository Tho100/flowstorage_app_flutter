import 'package:flutter/material.dart';

class TempStorageProvider extends ChangeNotifier {

  Set<String> _offlineFileNameList = <String>{};

  List<String> _statsFileNameList = <String>[];
  List<String> _folderNameList = <String>[];

  List<String> get statsFileNameList => _statsFileNameList;
  List<String> get folderNameList => _folderNameList;

  Set<String> get offlineFileNameList => _offlineFileNameList;

  void setStatsFilesName(List<String> statisticsFilesName) {
    _statsFileNameList = statisticsFilesName;
    notifyListeners();
  }

  void setFoldersName(List<String> folderName) {
    _folderNameList = folderName;
    notifyListeners();
  }

  void setOfflineFilesName(Set<String> offlineFilesName) {
    _offlineFileNameList = offlineFilesName;
    notifyListeners();
  }

  void addOfflineFileName(String name) {
    _offlineFileNameList.add(name);
    notifyListeners();
  }

}
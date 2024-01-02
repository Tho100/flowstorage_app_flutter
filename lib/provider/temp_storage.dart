import 'package:flutter/material.dart';

class TempStorageProvider extends ChangeNotifier {

  Set<String> _offlineFileNameList = <String>{};

  List<String> _statsFileNameList = <String>[];
  List<String> _folderNameList = <String>[];
  List<String> _directoryNameList = <String>[];

  List<String> get statsFileNameList => _statsFileNameList;
  List<String> get folderNameList => _folderNameList;
  List<String> get directoryNameList => _directoryNameList;

  Set<String> get offlineFileNameList => _offlineFileNameList;

  void setStatsFilesName(List<String> statisticsFilesName) {
    _statsFileNameList = statisticsFilesName;
    notifyListeners();
  }

  void setFoldersName(List<String> folderName) {
    _folderNameList = folderName;
    notifyListeners();
  }

  void setDirectoriesName(List<String> directoryName) {
    _directoryNameList = directoryName;
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
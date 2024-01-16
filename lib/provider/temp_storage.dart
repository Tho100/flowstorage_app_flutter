import 'package:flutter/material.dart';

class TempStorageProvider extends ChangeNotifier {

  Set<String> _offlineFileNameList = <String>{};

  List<String> _statsFileNameList = <String>[];
  List<String> _folderNameList = <String>[];
  List<String> _directoryNameList = <String>[];
  List<String> _sharedNameList = <String>[];

  List<String> get statsFileNameList => _statsFileNameList;
  List<String> get folderNameList => _folderNameList;
  List<String> get directoryNameList => _directoryNameList;
  List<String> get sharedNameList => _sharedNameList;

  Set<String> get offlineFileNameList => _offlineFileNameList;

  void setSharedName(List<String> sharedName) {
    _sharedNameList = sharedName;
    notifyListeners();
  }

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
import 'dart:typed_data';

import 'package:flutter/material.dart';

class StorageDataProvider extends ChangeNotifier {

  Set<String> _offlineFilesName = <String>{};

  List<String> _statisticsFilesName = <String>[];

  List<String> _folderNamesList = <String>[];

  List<String> _fileNamesList = <String>[];
  List<String> _fileNamesFilteredList = <String>[];

  List<String> _fileDateList = <String>[];
  List<String> _fileDateFilteredList = <String>[];

  List<Uint8List> _homeImageBytesList = <Uint8List>[];
  List<Uint8List> _homeThumbnailBytesList = <Uint8List>[];

  List<Uint8List?> _imageBytesList = <Uint8List?>[];
  List<Uint8List?> _imageBytesFilteredList = <Uint8List?>[];
  List<Uint8List> _directoryImageBytesList = <Uint8List>[];

  List<String> get statisticsFilesName => _statisticsFilesName;
  Set<String> get offlineFilesName => _offlineFilesName;

  List<String> get foldersNameList => _folderNamesList;

  List<String> get fileNamesList => _fileNamesList;
  List<String> get fileNamesFilteredList => _fileNamesFilteredList;

  List<String> get fileDateFilteredList => _fileDateFilteredList;
  List<String> get fileDateList => _fileDateList;

  List<Uint8List?> get imageBytesList => _imageBytesList;
  List<Uint8List?> get imageBytesFilteredList => _imageBytesFilteredList;
  List<Uint8List> get directoryImageBytesList => _directoryImageBytesList;

  List<Uint8List> get homeImageBytesList => _homeImageBytesList;
  List<Uint8List> get homeThumbnailBytesList => _homeThumbnailBytesList;

  void updateRemoveFile(int indexOfFile) {
    _fileNamesList.removeAt(indexOfFile);
    _fileNamesFilteredList.removeAt(indexOfFile);
    _imageBytesList.removeAt(indexOfFile);
    _imageBytesFilteredList.removeAt(indexOfFile);
    _fileDateList.removeAt(indexOfFile);
    _fileDateFilteredList.removeAt(indexOfFile);
    notifyListeners();
  }

  void updateRenameFile(String newFileName, int indexOldFile, int indexOldFileSearched) {
    _fileNamesList[indexOldFile] = newFileName;
    _fileNamesFilteredList[indexOldFileSearched] = newFileName;
    notifyListeners();
  }

  void updateFilteredImageBytes(List<Uint8List?> bytes) {
    _imageBytesFilteredList.addAll(bytes);
    notifyListeners();
  }

  void updateImageBytes(List<Uint8List?> bytes) {
    _imageBytesList.addAll(bytes);
    notifyListeners();
  }

  void setStatsFilesName(List<String> statisticsFilesName) {
    _statisticsFilesName = statisticsFilesName;
    notifyListeners();
  }

  void setOfflineFilesName(Set<String> offlineFilesName) {
    _offlineFilesName = offlineFilesName;
    notifyListeners();
  }

  void addOfflineFileName(String name) {
    _offlineFilesName.add(name);
    notifyListeners();
  }

  void setFoldersName(List<String> folderName) {
    _folderNamesList = folderName;
    notifyListeners();
  }

  void setFilesName(List<String> filesName) {
    _fileNamesList = filesName;
    notifyListeners();
  }

  void setFilteredFilesName(List<String> filesName) {
    _fileNamesFilteredList = filesName;
    notifyListeners();
  }

  void setFilesDate(List<String> date) {
    _fileDateList = date;
    notifyListeners();
  }

  void setFilteredFilesDate(List<String> date) {
    _fileDateFilteredList = date;
    notifyListeners();
  }

  void setImageBytes(List<Uint8List?> bytes) {
    _imageBytesList = bytes;
    notifyListeners();
  }

  void setFilteredImageBytes(List<Uint8List?> bytes) {
    _imageBytesFilteredList = bytes;
    notifyListeners();
  }

  void setDirectoryImageBytes(List<Uint8List> bytes) {
    _directoryImageBytesList = bytes;
    notifyListeners();
  }

  void setHomeImageBytes(List<Uint8List> bytes) {
    _homeImageBytesList = bytes;
    notifyListeners();
  }

  void setHomeThumbnailBytes(List<Uint8List> bytes) {
    _homeThumbnailBytesList = bytes;
    notifyListeners();
  }

}
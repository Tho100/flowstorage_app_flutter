import 'dart:io';
import 'dart:typed_data';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';
import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';
import 'package:flowstorage_fsc/directory_query/directory_data.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/folder_query/folder_data_retriever.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/public_storage_query/count_upload.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/public_storage_query/data_retriever.dart';
import 'package:flowstorage_fsc/sharing_query/sharing_data_receiver.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/just_loading.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:path/path.dart' as path;

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';

class DataCaller {

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final userData = GetIt.instance<UserDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final _crud = Crud();
  final _offlineMode = OfflineMode();
  
  final _fileNameGetterHome = NameGetter();
  final _dataGetterHome = DataRetriever();
  final _dateGetterHome = DateGetter();
  
  final _directoryDataReceiver = DirectoryDataReceiver();
  final _folderDataReceiver = FolderDataReceiver();
  final _sharingDataRetriever = SharingDataReceiver();

  Future<void> offlineData() async {

    tempData.setOrigin(OriginFile.offline);
    tempData.setAppBarTitle("Offline");

    final getAssets = GetAssets();
    final offlineDirPath = await _offlineMode.returnOfflinePath();

    if(!offlineDirPath.existsSync()) { 
      offlineDirPath.createSync();
    }
    
    final files = offlineDirPath.listSync().whereType<File>().toList();

    List<String> fileValues = [];
    List<String> filteredSearchedFiles = [];
    List<String> setDateValues = [];
    List<Uint8List> imageByteValues = [];
    List<Uint8List> filteredSearchedBytes = [];

    for (final file in files) {

      final lastModified = file.lastModifiedSync();
      final formattedDate = DateFormat('MMM d yyyy')
                              .format(lastModified);

      String fileName = path.basename(file.path);
      String? fileType = fileName.split('.').last;

      Uint8List imageBytes;
      String actualFileSize = '';

      final fileBytes = await file.readAsBytes();
      final fileSize = fileBytes.length;
      final fileSizeMB = fileSize / (1024 * 1024);

      actualFileSize = "${fileSizeMB.toStringAsFixed(2)}Mb";

      if (Globals.imageType.contains(fileType)) {
        imageBytes = await file.readAsBytes();

      } else if (Globals.textType.contains(fileType)) {
        imageBytes = await getAssets.loadAssetsData("txt0.jpg");

      } else if (Globals.audioType.contains(fileType)) {
        imageBytes = await getAssets.loadAssetsData("music0.jpg");

      } else if (fileType == "pdf") {
        imageBytes = await getAssets.loadAssetsData("pdf0.jpg");

      } else if (Globals.wordType.contains(fileType)) {
        imageBytes = await getAssets.loadAssetsData("doc0.jpg");

      } else if (Globals.excelType.contains(fileType)) {
        imageBytes = await getAssets.loadAssetsData("exl0.jpg");

      } else if (fileType == "exe") {
        imageBytes = await getAssets.loadAssetsData("exe0.jpg");

      } else if (fileType == "apk") {
        imageBytes = await getAssets.loadAssetsData("apk0.jpg");

      } else if (Globals.ptxType.contains(fileType)) {
        imageBytes = await getAssets.loadAssetsData("pptx0.jpg");

      } else {
        continue;
      }

      fileValues.add(fileName);
      filteredSearchedFiles.add(fileName);
      setDateValues.add("$actualFileSize ${GlobalsStyle.dotSeperator} $formattedDate");
      imageByteValues.add(imageBytes);
      filteredSearchedBytes.add(imageBytes);
    }

    storageData.setFilesName(fileValues);
    storageData.setFilteredFilesName(filteredSearchedFiles);
    storageData.setFilteredFilesDate(setDateValues);
    storageData.setFilesDate(setDateValues);
    storageData.setImageBytes(imageByteValues);
    storageData.setFilteredImageBytes(filteredSearchedBytes);

  }

  Future<void> homeData({bool? isFromStatistics = false}) async {

    final conn = await SqlConnection.initializeConnection();

    final futures = await startupDataCaller(
      conn: conn, username: userData.username);

    final results = await Future.wait(futures);

    final fileNames = <String>{};
    final bytes = <Uint8List>[];
    final dates = <String>[];

    for (final result in results) {
      final fileNamesForTable = result[0] as List<String>;
      final bytesForTable = result[1] as List<Uint8List>;
      final datesForTable = result[2] as List<String>;

      fileNames.addAll(fileNamesForTable);
      bytes.addAll(bytesForTable);
      dates.addAll(datesForTable);
    }

    final uniqueFileNames = fileNames.toList();
    final uniqueBytes = bytes.toList();

    if(isFromStatistics!) {
      tempStorageData.setStatsFilesName(uniqueFileNames);
      return;
    }

    storageData.setFilesName(uniqueFileNames);
    storageData.setImageBytes(uniqueBytes);
    storageData.setFilesDate(dates);
    
    tempData.setAppBarTitle("Home");

    storageData.fileNamesFilteredList.clear();
    storageData.imageBytesFilteredList.clear();

  }

  Future<void> publicStorageData({required BuildContext context}) async {

    final justLoading = JustLoading();

    justLoading.startLoading(context: context);

    if(psStorageData.psImageBytesList.isEmpty) {
      final uploadCount = await PublicStorageCountTotalUpload()
        .countTotalFilesUploaded();

      tempData.setPsTotalUpload(uploadCount);

    }

    final psDataRetriever = PublicStorageDataRetriever();
    final dataList = await psDataRetriever.retrieveParams(isFromMyPs: false);

    final uploaderList = dataList.expand((data) => data['uploader_name'] as List<String>).toList();
    final nameList = dataList.expand((data) => data['name'] as List<String>).toList();
    final fileDateList = dataList.expand((data) => data['date'] as List<String>).toList();
    final byteList = dataList.expand((data) => data['file_data'] as List<Uint8List>).toList();
    final titleList = dataList.expand((data) => data['titles'] as List<String>).toList();

    final getTagsValue = fileDateList.
      map((tags) => tags.split(' ').last).toList();

    psStorageData.psTagsList.addAll(getTagsValue);
    psStorageData.psUploaderList.addAll(uploaderList);
    psStorageData.psTitleList.addAll(titleList);

    storageData.setFilesName(nameList);
    storageData.setFilesDate(fileDateList);
    storageData.setImageBytes(byteList);

    tempData.setOrigin(OriginFile.public);
    tempData.setAppBarTitle("Public Storage");

    justLoading.stopLoading();
    
  }

  Future<void> myPublicStorageData({required BuildContext context}) async {

    final justLoading = JustLoading();

    justLoading.startLoading(context: context);

    psStorageData.psImageBytesList.clear();
    psStorageData.psUploaderList.clear();
    psStorageData.psThumbnailBytesList.clear();

    psStorageData.psTagsList.clear();
    psStorageData.psTagsColorList.clear();
    psStorageData.psTitleList.clear();

    final psDataRetriever = PublicStorageDataRetriever();
    final dataList = await psDataRetriever.retrieveParams(isFromMyPs: true);

    final uploaderList = dataList.expand((data) => data['uploader_name'] as List<String>).toList();
    final nameList = dataList.expand((data) => data['name'] as List<String>).toList();
    final fileDateList = dataList.expand((data) => data['date'] as List<String>).toList();
    final byteList = dataList.expand((data) => data['file_data'] as List<Uint8List>).toList();
    final titleList = dataList.expand((data) => data['titles'] as List<String>).toList();

    final getTagsValue = fileDateList.
      map((tags) => tags.split(' ').last).toList();

    psStorageData.psTagsList.addAll(getTagsValue);
    psStorageData.psUploaderList.addAll(uploaderList);
    psStorageData.psTitleList.addAll(titleList);

    storageData.setFilesName(nameList);
    storageData.setFilesDate(fileDateList);
    storageData.setImageBytes(byteList);

    tempData.setOrigin(OriginFile.public);
    tempData.setAppBarTitle("My Public Storage");

    justLoading.stopLoading();
    
  }

  Future<void> directoryData({required String directoryName}) async {

    final dataList = await _directoryDataReceiver.retrieveParams(dirName: directoryName);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final fileDateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();
    
    storageData.setFilesName(nameList);
    storageData.setFilesDate(fileDateList);
    storageData.setImageBytes(byteList);

    tempData.setOrigin(OriginFile.directory);

  }

  Future<void> sharingData(String originFrom) async {

    final dataList = await _sharingDataRetriever.retrieveParams(userData.username,originFrom);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final fileDateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();

    storageData.setFilesName(nameList);
    storageData.setFilesDate(fileDateList);
    storageData.setImageBytes(byteList);

    if(originFrom == "sharedFiles") {
      tempData.setOrigin(OriginFile.sharedOther);
      tempData.setAppBarTitle("Shared files");
      
    } else {
      tempData.setOrigin(OriginFile.sharedMe);
      tempData.setAppBarTitle("Shared to me");

    }

  }

  Future<void> folderData({required String folderName}) async {

    final dataList = await _folderDataReceiver.retrieveParams(userData.username, folderName);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final fileDateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();

    storageData.setFilesName(nameList);
    storageData.setFilesDate(fileDateList);
    storageData.setImageBytes(byteList);

    tempData.setOrigin(OriginFile.folder);
    tempData.setAppBarTitle(tempData.folderName);

  }

  Future<List<Future<List<List<Object>>>>> startupDataCaller({
    required MySQLConnectionPool conn,
    required String username,
  }) async {

    final dirListCount = await _crud.countUserTableRow(GlobalsTable.directoryInfoTable);
    final dirLists = List.generate(dirListCount, (_) => GlobalsTable.directoryInfoTable);

    final tablesToCheck = [
      ...dirLists,
      GlobalsTable.homeImage, GlobalsTable.homeText, 
      GlobalsTable.homeVideo, GlobalsTable.homePdf,
      GlobalsTable.homeAudio, GlobalsTable.homeExcel, 
      GlobalsTable.homePtx, GlobalsTable.homeWord,
      GlobalsTable.homeExe, GlobalsTable.homeApk
    ];

    return tablesToCheck.map((table) async {
      final fileNames = await _fileNameGetterHome.retrieveParams(conn, username, table);
      final bytes = await _dataGetterHome.getLeadingParams(conn, username, table);
      final dates = table == GlobalsTable.directoryInfoTable
          ? ["Directory"]
          : await _dateGetterHome.retrieveParams(conn, username, table);
      return [fileNames, bytes, dates];
    }).toList();

  }

}
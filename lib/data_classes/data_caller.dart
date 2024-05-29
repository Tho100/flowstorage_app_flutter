import 'dart:io';
import 'dart:typed_data';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_classes/file_data_getter.dart';
import 'package:flowstorage_fsc/data_classes/file_date_getter.dart';
import 'package:flowstorage_fsc/data_classes/file_name_getter.dart';
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
import 'package:flowstorage_fsc/ui_dialog/loading/call_ps_loading.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:path/path.dart' as path;

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/models/offline_model.dart';

class DataCaller {

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final userData = GetIt.instance<UserDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final _crud = Crud();
  final _offlineMode = OfflineModel();
  
  final _fileNameGetterHome = FileNameGetter();
  final _dataGetterHome = FileDataGetter();
  final _dateGetterHome = FileDateGetter();
  
  final _directoryDataReceiver = DirectoryDataReceiver();
  final _folderDataReceiver = FolderDataReceiver();
  final _sharingDataRetriever = SharingDataReceiver();

  void _initializeData({
    required Set<String> fileName, 
    required Set<Uint8List> fileData, 
    required List<String> date
  }) {
    storageData.setFilesName(fileName.toList());
    storageData.setImageBytes(fileData.toList());
    storageData.setFilesDate(date);
  }

  Future<void> offlineData() async {

    tempData.setOrigin(OriginFile.offline);
    tempData.setAppBarTitle("Offline");

    final getAssets = GetAssets();
    final offlineDirPath = await _offlineMode.returnOfflinePath();

    if(!offlineDirPath.existsSync()) {
      offlineDirPath.createSync();
    }
    
    final files = offlineDirPath.listSync().whereType<File>().toList();

    final fileNames = <String>{};
    final bytes = <Uint8List>{};
    final dates = <String>[];

    for (final file in files) {

      final lastModified = file.lastModifiedSync();
      final formattedDate = DateFormat('MMM d yyyy')
                              .format(lastModified);

      final fileName = path.basename(file.path);
      final fileType = fileName.split('.').last;

      final fileBytes = await file.readAsBytes();
      final fileSize = fileBytes.length;
      final fileSizeMB = fileSize / (1024 * 1024);

      final actualFileSize = "${fileSizeMB.toStringAsFixed(2)}Mb";

      final imageBytes = Globals.imageType.contains(fileType)
        ? await file.readAsBytes()
        : await getAssets.loadAssetsData(Globals.fileTypeToAssets[fileType]!);

      fileNames.add(fileName);
      dates.add("$actualFileSize ${GlobalsStyle.dotSeparator} $formattedDate");
      bytes.add(imageBytes);

    }

    _initializeData(
      fileName: fileNames, fileData: bytes, date: dates);

  }

  Future<void> homeData() async {

    final conn = await SqlConnection.initializeConnection();

    final futures = await getStartupData(
      conn: conn, username: userData.username);

    final results = await Future.wait(futures);

    final fileNames = <String>{};
    final bytes = <Uint8List>{};
    final dates = <String>[];

    for (final result in results) {
      final fileName = result[0] as List<String>;
      final fileData = result[1] as List<Uint8List>;
      final uploadDate = result[2] as List<String>;

      fileNames.addAll(fileName);
      bytes.addAll(fileData);
      dates.addAll(uploadDate);
    }

    _initializeData(
      fileName: fileNames, fileData: bytes, date: dates);

    storageData.fileNamesFilteredList.clear();
    storageData.imageBytesFilteredList.clear();

  }

  Future<void> statisticsData() async {

    final conn = await SqlConnection.initializeConnection();

    final tablesToCheck = Set<String>.from(GlobalsTable.tableNames);
    tablesToCheck.remove(GlobalsTable.directoryUploadTable);

    final getFileNames = tablesToCheck.map((table) async {
      final fileNames = await _fileNameGetterHome.getFileName(conn, userData.username, table);
      return [fileNames];
    }).toList();

    final futures = await Future.wait(getFileNames);

    final fileNames = <String>[];

    for (final result in futures) {
      final fileNamesForTable = result[0];
      fileNames.addAll(fileNamesForTable);
    }

    tempStorageData.setStatsFilesName(fileNames);

  }

  Future<void> publicStorageData({required BuildContext context}) async {

    final psLoading = CallPsLoading(context: context);

    psLoading.startLoading();

    if(psStorageData.psImageBytesList.isEmpty) {
      final uploadCount = await PublicStorageCountTotalUpload()
        .countTotalFilesUploaded();

      tempData.setPsTotalUpload(uploadCount);

    }

    final dataList = await PublicStorageDataRetriever()
      .getFilesInfo(isFromMyPs: false);

    final fileNames = <String>{};
    final bytes = <Uint8List>{};
    final dates = <String>[];

    final uploader = <String>[];
    final titles = <String>[];

    for (final result in dataList) {
      final fileName = result['name'] as List<String>;
      final fileData = result['file_data'] as List<Uint8List>;
      final uploadDate = result['date'] as List<String>;

      final fileUploader = result['uploader_name'] as List<String>;
      final fileTitle = result['titles'] as List<String>;

      fileNames.addAll(fileName);
      bytes.addAll(fileData);
      dates.addAll(uploadDate);
      uploader.addAll(fileUploader);
      titles.addAll(fileTitle);
    }

    final getTagsValue = dates.map((tags) => tags.split(' ').last).toList();

    psStorageData.psTagsList.addAll(getTagsValue);
    psStorageData.psUploaderList.addAll(uploader);
    psStorageData.psTitleList.addAll(titles);

    psStorageData.setFromMyPs(false);

    _initializeData(
      fileName: fileNames, fileData: bytes, date: dates);

    tempData.setOrigin(OriginFile.public);
    tempData.setAppBarTitle("Public Storage");

    psLoading.stopLoading();
    
  }

  Future<void> myPublicStorageData({required BuildContext context}) async {

    final psLoading = CallPsLoading(context: context);

    psLoading.startLoading();

    psStorageData.psImageBytesList.clear();
    psStorageData.psUploaderList.clear();
    psStorageData.psThumbnailBytesList.clear();

    psStorageData.psTagsList.clear();
    psStorageData.psTagsColorList.clear();
    psStorageData.psTitleList.clear();

    final dataList = await PublicStorageDataRetriever()
      .getFilesInfo(isFromMyPs: true);

    final fileNames = <String>{};
    final bytes = <Uint8List>{};
    final dates = <String>[];

    final uploader = <String>[];
    final titles = <String>[];

    for (final result in dataList) {
      final fileName = result['name'] as List<String>;
      final fileData = result['file_data'] as List<Uint8List>;
      final uploadDate = result['date'] as List<String>;

      final fileUploader = result['uploader_name'] as List<String>;
      final fileTitle = result['titles'] as List<String>;

      fileNames.addAll(fileName);
      bytes.addAll(fileData);
      dates.addAll(uploadDate);
      uploader.addAll(fileUploader);
      titles.addAll(fileTitle);
    }

    final getTagsValue = dates.map((tags) => tags.split(' ').last).toList();

    psStorageData.psTagsList.addAll(getTagsValue);
    psStorageData.psUploaderList.addAll(uploader);
    psStorageData.psTitleList.addAll(titles);

    psStorageData.setFromMyPs(true);

    _initializeData(
      fileName: fileNames, fileData: bytes, date: dates);

    tempData.setOrigin(OriginFile.public);
    tempData.setAppBarTitle("My Public Storage");

    psLoading.stopLoading();
    
  }

  Future<void> directoryData({required String directoryName}) async {

    final dataList = await _directoryDataReceiver.retrieveParams(dirName: directoryName);

    final nameList = dataList.map((data) => data['name'] as String).toSet();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toSet();
    final dateList = dataList.map((data) => data['date'] as String).toList();
    
    _initializeData(
      fileName: nameList, fileData: byteList, date: dateList);

    tempData.setOrigin(OriginFile.directory);

  }

  Future<void> sharingData(String originFrom) async {

    final dataList = await _sharingDataRetriever.retrieveParams(userData.username,originFrom);

    final nameList = dataList.map((data) => data['name'] as String).toList();
    final dateList = dataList.map((data) => data['date'] as String).toList();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();

    storageData.setFilesName(nameList);
    storageData.setFilesDate(dateList);
    storageData.setImageBytes(byteList);

    final sharedNames = dateList.map((string) {
      final dotIndex = string.indexOf(GlobalsStyle.dotSeparator);
      return dotIndex != -1 ? string.substring(0, dotIndex-1) : string;
    }).toList();

    tempStorageData.setSharedName(sharedNames);

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

    final nameList = dataList.map((data) => data['name'] as String).toSet();
    final byteList = dataList.map((data) => data['file_data'] as Uint8List).toSet();
    final dateList = dataList.map((data) => data['date'] as String).toList();

    _initializeData(
      fileName: nameList, fileData: byteList, date: dateList);

    tempData.setOrigin(OriginFile.folder);
    tempData.setAppBarTitle(tempData.folderName);

  }

  Future<List<Future<List<List<Object>>>>> getStartupData({
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
      final fileNames = await _fileNameGetterHome.getFileName(conn, username, table);
      final bytes = await _dataGetterHome.getLeadingParams(conn, username, table);
      final dates = table == GlobalsTable.directoryInfoTable
        ? ["Directory"]
        : await _dateGetterHome.getUploadDate(conn, username, table);
      return [fileNames, bytes, dates];
    }).toList();

  }

}
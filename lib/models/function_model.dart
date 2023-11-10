import 'dart:typed_data';

import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_query/delete_data.dart';
import 'package:flowstorage_fsc/data_query/rename_data.dart';
import 'package:flowstorage_fsc/data_query/retrieve_data.dart';
import 'package:flowstorage_fsc/directory_query/create_directory.dart';
import 'package:flowstorage_fsc/directory_query/delete_directory.dart';
import 'package:flowstorage_fsc/directory_query/save_directory.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/folder_query/rename_folder.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/helper/simplify_download.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/multiple_text_loading.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class FunctionModel {

  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  final logger = Logger();

  Future<Uint8List> _callFileByteData(String selectedFilename, String tableName) async {
    return await RetrieveData().retrieveDataParams(userData.username, selectedFilename, tableName);
  }

  Future<void> renameFolderData(String oldFolderName, String newFolderName) async {

    try {

      await RenameFolder(
        oldFolderTitle: oldFolderName, 
        newFolderTitle: newFolderName).rename();

      final indexOldFolder = storageData.foldersNameList.indexWhere((name) => name == oldFolderName);
      if(indexOldFolder != -1) {
        storageData.foldersNameList[indexOldFolder] = newFolderName;
      }

      await CallNotify().customNotification(title: "Folder Renamed", subMesssage: "$oldFolderName renamed to $newFolderName");

      SnakeAlert.okSnake(message: "`$oldFolderName` Has been renamed to `$newFolderName`");

    } catch (err) {
      SnakeAlert.errorSnake("Failed to rename this folder.");
    }

  }

  Future<void> deleteFileData(String username, String fileName, String tableName) async {

    try {

      if(tempData.origin == OriginFile.offline) {
        await OfflineMode().deleteFile(fileName);
        SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been deleted");
        return;

      } 

      final encryptVals = EncryptionClass().encrypt(fileName);
      await DeleteData().deleteFiles(username: username, fileName: encryptVals, tableName: tableName);
      
      SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been deleted");

    } catch (err, st) {
      logger.e('Exception from _deletionFile {function_model}',err,st);
      SnakeAlert.errorSnake("Failed to delete ${ShortenText().cutText(fileName)}");
    }

  }

  Future<void> renameFileData(String oldFileName, String newFileName) async {
    
    final fileType = oldFileName.split('.').last;
    final tableName = Globals.fileTypesToTableNames[fileType]!;

    try {
      
      tempData.origin != OriginFile.offline 
        ? await RenameData().renameFiles(oldFileName, newFileName, tableName) 
        : await OfflineMode().renameFile(oldFileName,newFileName);

      int indexOldFile = storageData.fileNamesList.indexOf(oldFileName);
      int indexOldFileSearched = storageData.fileNamesFilteredList.indexOf(oldFileName);

      if (indexOldFileSearched != -1) {
        storageData.updateRenameFile(
            newFileName, indexOldFile, indexOldFileSearched);

        SnakeAlert.okSnake(message: "`${ShortenText().cutText(oldFileName)}` Renamed to `${ShortenText().cutText(newFileName)}`.");
      }

    } catch (err, st) {
      logger.e('Exception from _renameFile {function_model}', err, st);
      SnakeAlert.errorSnake("Failed to rename this file.");
    }

  }

  Future<void> multipleFilesDownload({
    required int count,
    required String directoryPath,
    required Set<String> checkedItemsName
  }) async {

    try {

      final loadingDialog = SingleTextLoading();      
      loadingDialog.startLoading(title: "Saving...", context: navigatorKey.currentContext!);

      for(int i=0; i<count; i++) {

        late Uint8List getBytes;

        final fileType = checkedItemsName.elementAt(i).split('.').last;
        final tableName = Globals.fileTypesToTableNames[fileType];

        if(Globals.imageType.contains(fileType)) {
          final fileIndex = storageData.fileNamesFilteredList.indexOf(checkedItemsName.elementAt(i));
          getBytes = storageData.imageBytesFilteredList.elementAt(fileIndex)!;

        } else {
          getBytes = CompressorApi.compressByte(await _callFileByteData(checkedItemsName.elementAt(i),tableName!));

        }

        await SaveApi().saveMultipleFiles(directoryPath: directoryPath, fileName: checkedItemsName.elementAt(i), fileData: getBytes);

      }

      loadingDialog.stopLoading();

      SnakeAlert.okSnake(message: "$count item(s) has been saved.",icon: Icons.check);

    } catch (err) {
      SnakeAlert.errorSnake("Failed to save files.");
    }

  }

  Future<void> downloadFileData({required String fileName}) async {

    try {

      final fileType = fileName.split('.').last;
      final tableName = tempData.origin != OriginFile.home 
                        ? Globals.fileTypesToTableNamesPs[fileType] 
                        : Globals.fileTypesToTableNames[fileType];

      final isItemDirectory = fileType == fileName;

      if(isItemDirectory) {
        await SaveDirectory().selectDirectoryUserDirectory(directoryName: fileName, context: navigatorKey.currentContext!);
        return;
        
      }

      final loadingDialog = MultipleTextLoading();
      
      loadingDialog.startLoading(title: "Downloading...", subText: "File name  $fileName", context: navigatorKey.currentContext!);

      if(tempData.origin != OriginFile.offline) {

        late Uint8List getBytes;

        if(Globals.imageType.contains(fileType)) {
          int imageIndex = storageData.fileNamesFilteredList.indexOf(fileName);
          getBytes = storageData.imageBytesFilteredList[imageIndex]!;

        } else {
          getBytes = CompressorApi.compressByte(await _callFileByteData(fileName, tableName!));

        }

        await SimplifyDownload(
          fileName: fileName,
          currentTable: tableName!,
          fileData: getBytes
        ).downloadFile();

      } else {
        await OfflineMode().downloadFile(fileName);

      } 

      loadingDialog.stopLoading();

      await CallNotify().downloadedNotification(fileName: fileName);

      SnakeAlert.okSnake(message: "${ShortenText().cutText(fileName)} Has been downloaded.",icon: Icons.check);

    } catch (err) {
      await CallNotify().customNotification(title: "Download Failed", subMesssage: "Failed to download $fileName.");
      SnakeAlert.errorSnake("Failed to download ${ShortenText().cutText(fileName)}");
    }

  }

  Future<void> createDirectoryData(String directoryName) async {

    try {

      await CreateDirectory(name: directoryName).create();

      final directoryImage = await GetAssets().loadAssetsFile('dir1.jpg');

      storageData.fileDateFilteredList.add("Directory");
      storageData.fileDateList.add("Directory");
      storageData.imageBytesList.add(directoryImage.readAsBytesSync());
      storageData.imageBytesFilteredList.add(directoryImage.readAsBytesSync());

      storageData.directoryImageBytesList.clear();
      storageData.fileNamesFilteredList.add(directoryName);
      storageData.fileNamesList.add(directoryName);

      SnakeAlert.okSnake(message: "Directory $directoryName has been created.", icon: Icons.check);

    } catch (err, st) {
      logger.e('Exception from _buildDirectory {function_model}',err,st);
      CustomAlertDialog.alertDialog('Failed to create directory.');
    }
  }
  
  Future<void> deleteDirectoryData(String directoryName) async {

    try {

      await DeleteDirectory(name: directoryName).delete();
    
      storageData.directoryImageBytesList.clear();

      SnakeAlert.okSnake(message: "Directory `$directoryName` has been deleted.");

    } catch (err, st) {
      logger.e('Exception from _deletionDirectory {function_model}',err,st);
      SnakeAlert.errorSnake("Failed to delete $directoryName");
    }

  }

  Future<void> makeAvailableOffline({
    required String fileName
  }) async {

    try {

      final offlineMode = OfflineMode();
      final singleLoading = SingleTextLoading();

      final fileType = fileName.split('.').last;
      final tableName = Globals.fileTypesToTableNames[fileType]!;

      if(storageData.offlineFilesName.contains(fileName)) {
        CustomFormDialog.startDialog(ShortenText().cutText(fileName, customLength: 36), "This file is already available for offline mode.");
        return;
      }

      if(Globals.unsupportedOfflineModeTypes.contains(fileType)) {
        CustomFormDialog.startDialog(ShortenText().cutText(fileName, customLength: 36), "This file is unavailable for offline mode.");
        return;
      } 

      late final Uint8List fileData;
      final indexFile = storageData.fileNamesList.indexOf(fileName);

      singleLoading.startLoading(title: "Preparing...", context: navigatorKey.currentContext!);

      if(Globals.imageType.contains(fileType)) {
        fileData = tempData.origin != OriginFile.public 
          ? storageData.imageBytesFilteredList[indexFile]! 
          : psStorageData.psImageBytesList[indexFile];
        
      } else {
        fileData = CompressorApi.compressByte(await _callFileByteData(fileName, tableName));
        
      }
      
      await offlineMode.processSaveOfflineFile(fileName: fileName, fileData: fileData);

      singleLoading.stopLoading();

    } catch (err, st) {
      logger.e('Exception from _deletionDirectory {function_model}',err,st); 
    }

  }

}
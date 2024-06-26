import 'dart:convert';
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
import 'package:flowstorage_fsc/models/offline_model.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class FunctionModel {

  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();

  final userData = GetIt.instance<UserDataProvider>();

  final logger = Logger();

  Future<Uint8List> _callFileByteData(String selectedFilename, String tableName) async {
    return await RetrieveData()
      .getFileData(userData.username, selectedFilename, tableName);
  }

  Future<void> renameFolderData(String oldFolderName, String newFolderName) async {

    try {

      await RenameFolder(
        oldFolderTitle: oldFolderName, 
        newFolderTitle: newFolderName).rename();

      final indexOldFolder = tempStorageData.folderNameList.indexWhere((name) => name == oldFolderName);
      if(indexOldFolder != -1) {
        tempStorageData.folderNameList[indexOldFolder] = newFolderName;
      }

      await CallNotify().customNotification(title: "Folder Renamed", subMessage: "'$oldFolderName' renamed to '$newFolderName'");

      SnackAlert.okSnack(message: "'$oldFolderName' Has been renamed to '$newFolderName'");

    } catch (err, st) {
      logger.e('Exception from renameFolderData {function_model}', err, st);
      SnackAlert.errorSnack("Failed to rename this folder.");
    }

  }

  Future<void> deleteFileData(String username, String fileName, String tableName) async {

    try {

      if(tempData.origin == OriginFile.offline) {
        await OfflineModel().deleteFile(fileName);
        SnackAlert.okSnack(message: "Deleted $fileName", icon: Icons.check);
        return;
      } 

      final encryptedFileName = EncryptionClass().encrypt(fileName);
      await DeleteData().deleteFiles(username: username, fileName: encryptedFileName, tableName: tableName);
      
      tempData.clearFileData();

      SnackAlert.okSnack(message: "Deleted $fileName", icon: Icons.check);

    } catch (err, st) {
      logger.e('Exception from deleteFileData {function_model}', err, st);
      SnackAlert.errorSnack("Failed to delete $fileName");
    }

  }

  Future<void> renameFileData(String oldFileName, String newFileName) async {
    
    try {
      
      final fileType = oldFileName.split('.').last;
      final tableName = Globals.fileTypesToTableNames[fileType]!;
      
      tempData.origin != OriginFile.offline
        ? await RenameData().renameFiles(oldFileName, newFileName, tableName) 
        : await OfflineModel().renameFile(oldFileName, newFileName);

      final indexOldFile = storageData.fileNamesList.indexOf(oldFileName);
      final indexOldFileSearched = storageData.fileNamesFilteredList.indexOf(oldFileName);

      if (indexOldFileSearched != -1) {
        storageData.updateRenameFile(
            newFileName, indexOldFile, indexOldFileSearched);   
        
        if(tempData.origin == OriginFile.offline) {
          tempStorageData.offlineFileNameList.remove(oldFileName);
          tempStorageData.offlineFileNameList.add(newFileName);
        }

        SnackAlert.okSnack(message: "'$oldFileName' renamed to '$newFileName'");
        
      }

    } catch (err, st) {
      logger.e('Exception from renameFileData {function_model}', err, st);
      SnackAlert.errorSnack("Failed to rename this file.");
    }

  }

  Future<void> multipleFilesDownload({
    required Set<String> checkedItemsName
  }) async {

    final loadingDialog = SingleTextLoading();

    loadingDialog.startLoading(title: "Saving...", context: navigatorKey.currentContext!);

    try {

      for(final fileName in checkedItemsName) {

        final fileType = fileName.split('.').last;
        final tableName = Globals.fileTypesToTableNames[fileType];

        final getBytes = Globals.imageType.contains(fileType)
            ? storageData.imageBytesFilteredList.elementAt(
                storageData.fileNamesFilteredList.indexOf(fileName))!
            : (tempData.origin == OriginFile.offline
                ? await OfflineModel().loadOfflineFileByte(fileName)
                : await _callFileByteData(fileName, tableName!));

        await SaveApi().saveFile(
          fileName: fileName, 
          fileData: getBytes
        );

      }

      loadingDialog.stopLoading();

      SnackAlert.okSnack(message: "${checkedItemsName.length} item(s) has been saved.", icon: Icons.check);

    } catch (err, st) {
      logger.e('Exception from multipleFilesDownload {function_model}', err, st);
      loadingDialog.stopLoading();
      SnackAlert.errorSnack("Failed to save files.");
    }

  }

  Future<void> downloadFileData({required String fileName}) async {

    final loadingDialog = SingleTextLoading();

    try {

      final fileType = fileName.contains('.') 
        ? fileName.split('.').last
        : fileName;
      
      final isItemDirectory = fileType == fileName;

      if(isItemDirectory) {
        await SaveDirectory().downloadDirectoryFiles(directoryName: fileName);
        return;
      }
      
      loadingDialog.startLoading(title: "Downloading...", context: navigatorKey.currentContext!);

      final tableName = tempData.origin != OriginFile.home 
        ? Globals.fileTypesToTableNamesPs[fileType]! 
        : Globals.fileTypesToTableNames[fileType]!;

      if(tempData.origin != OriginFile.offline) {

        final fileData = Globals.imageType.contains(fileType) 
          ? storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexOf(fileName)]!
          : await _callFileByteData(fileName, tableName);

        await SimplifyDownload(
          fileName: fileName,
          currentTable: tableName,
          fileData: fileData
        ).downloadFile();

      } else {
        await OfflineModel().downloadFile(fileName);

      } 

      loadingDialog.stopLoading();

      await CallNotify().downloadedNotification(fileName: fileName);

      if(Globals.imageType.contains(fileType) || Globals.videoType.contains(fileType)) {
        SnackAlert.okSnack(message: "$fileName Saved to gallery.", icon: Icons.check);

      } else {
        SnackAlert.okSnack(message: "$fileName Has been downloaded.", icon: Icons.check);

      }


    } catch (err, st) {
      logger.e('Exception from downloadFileData {function_model}', err, st);
      loadingDialog.stopLoading();
      await CallNotify().customNotification(title: "Download Failed", subMessage: "Failed to download $fileName.");
      SnackAlert.errorSnack("Failed to download $fileName.");
    }

  }

  Future<void> createDirectoryData(String directoryName) async {

    try {

      final isDirectoryCreated = await CreateDirectory(name: directoryName).create();

      if(isDirectoryCreated) {

        final directoryImage = await GetAssets().loadAssetsFile('dir1.jpg');

        storageData.fileDateFilteredList.add("Directory");
        storageData.fileDateList.add("Directory");
        storageData.imageBytesList.add(directoryImage.readAsBytesSync());
        storageData.imageBytesFilteredList.add(directoryImage.readAsBytesSync());

        storageData.fileNamesFilteredList.add(directoryName);
        storageData.fileNamesList.add(directoryName);

        tempStorageData.directoryNameList.add(directoryName);

        SnackAlert.okSnack(message: "Directory $directoryName has been created.", icon: Icons.check);

      } else {
        SnackAlert.errorSnack("Failed to create directory.");
        
      }

    } catch (err, st) {
      logger.e('Exception from createDirectoryData {function_model}',err,st);
    }

  }
  
  Future<void> deleteDirectoryData(String directoryName) async {

    try {

      await DeleteDirectory(name: directoryName).delete();
    
      tempStorageData.directoryNameList.remove(directoryName);
      
      SnackAlert.okSnack(message: "Directory `$directoryName` has been deleted.");

    } catch (err, st) {
      logger.e('Exception from deleteDirectoryData {function_model}',err,st);
      SnackAlert.errorSnack("Failed to delete $directoryName");
    }

  }

  Uint8List returnImageDataForPublic(int originalIndex) {

    if(tempData.origin == OriginFile.publicSearching) {
      final index = psStorageData.psSearchNameList.indexOf(tempData.selectedFileName);
      return base64.decode(psStorageData.psSearchImageBytesList[index]);

    } 
    
    return psStorageData.isFromMyPs 
      ? psStorageData.myPsImageBytesList[originalIndex]
      : psStorageData.psImageBytesList[originalIndex];

  }

  Future<void> makeMultipleFilesAvailableOffline({
    required Set<String> checkedFilesName,
  }) async {

    final offlineMode = OfflineModel();
    final singleLoading = SingleTextLoading();

    for(final fileName in checkedFilesName) {

      final isAlreadyOffline = tempStorageData.offlineFileNameList.contains(fileName);

      if(isAlreadyOffline) {
        CustomFormDialog.startDialog("Something went wrong", "Selected file is already available for offline mode.");
        return;
      }

    }

    singleLoading.startLoading(title: "Preparing...", context: navigatorKey.currentContext!);

    for(final fileName in checkedFilesName) {

      final fileType = fileName.split('.').last;

      if(Globals.supportedFileTypes.contains(fileType)) {

        final tableName = Globals.fileTypesToTableNames[fileType]!;

        final fileData = Globals.imageType.contains(fileType)
          ? storageData.imageBytesFilteredList[
            storageData.fileNamesFilteredList.indexOf(fileName)]!
          : CompressorApi.compressByte(
            await _callFileByteData(fileName, tableName));

        await offlineMode.saveOfflineFile(
          fileName: fileName, 
          fileData: fileData
        );

        tempStorageData.addOfflineFileName(fileName);
          
      } 

    }

    singleLoading.stopLoading();

    SnackAlert.okSnack(message: "${checkedFilesName.length} Item(s) now available offline.", icon: Icons.check);

    await CallNotify().customNotification(title: "Offline", subMessage: "${checkedFilesName.length} Item(s) now available offline");

  }

  Future<void> makeAvailableOffline({
    required String fileName
  }) async {

    final singleLoading = SingleTextLoading();

    try {

      final fileType = fileName.split('.').last;
      final tableName = Globals.fileTypesToTableNames[fileType]!;

      final isAlreadyOffline = tempStorageData.offlineFileNameList.contains(fileName);

      if(isAlreadyOffline) {
        CustomFormDialog.startDialog(ShortenText().cutText(fileName, customLength: 36), "This file is already available for offline mode.");
        return;
      }
      
      final indexFile = storageData.fileNamesList.indexOf(fileName);

      singleLoading.startLoading(title: "Preparing...", context: navigatorKey.currentContext!);

      final isPublicOrigin = tempData.origin == OriginFile.public || tempData.origin == OriginFile.publicSearching;

      final fileData = Globals.imageType.contains(fileType)
        ? isPublicOrigin
            ? returnImageDataForPublic(indexFile)
            : storageData.imageBytesFilteredList[indexFile]!
        : CompressorApi.compressByte(
          await _callFileByteData(fileName, tableName));

      await OfflineModel().processSaveOfflineFile(fileName: fileName, fileData: fileData);

      tempStorageData.addOfflineFileName(fileName);

      singleLoading.stopLoading();

      await CallNotify().customNotification(title: "Offline", subMessage: "1 Item now available offline");

    } catch (err, st) {
      singleLoading.stopLoading();
      logger.e('Exception from makeAvailableOffline {function_model}', err, st); 
    }

  }

  Future<Uint8List> retrieveFileData({
    required String fileName, 
    required bool isCompressed
  }) async {

    try {

      final fileType = fileName.split('.').last;
      final fileTable = Globals.fileTypesToTableNames[fileType]!;
      
      if(Globals.imageType.contains(fileType)) {
        final index = storageData.fileNamesFilteredList.indexOf(fileName);
        return storageData.imageBytesFilteredList.elementAt(index)!;

      }

      if(tempData.origin != OriginFile.offline) {
        return isCompressed 
          ? CompressorApi.compressByte(
            await _callFileByteData(fileName, fileTable))
          : await _callFileByteData(fileName, fileTable);
       
      }

      return await OfflineModel().loadOfflineFileByte(fileName);

    } catch (err, st) {
      logger.e('Exception from retrieveFileData {function_model}', err, st); 
      return Uint8List(0);
    }
    
  }

  Future<Uint8List> retrieveFileDataPreviewer({
    required isCompressed
  }) async {

    try {

      final fileType = tempData.selectedFileName.split('.').last;

      if(Globals.imageType.contains(fileType)) {
        final index = storageData.fileNamesFilteredList.indexOf(tempData.selectedFileName);
        return storageData.imageBytesFilteredList.elementAt(index)!; 

      } 

      return isCompressed 
        ? CompressorApi.compressByte(tempData.fileByteData)
        : tempData.fileByteData;

    } catch (err, st) {
      logger.e('Exception from retrieveFileDataPreviewer {function_model}', err, st); 
      return Uint8List(0);
    }

  }

}
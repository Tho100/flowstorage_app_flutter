import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/generate_thumbnail.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/models/picker_model.dart';
import 'package:flowstorage_fsc/models/update_list_view.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:path/path.dart' as path;

class UploadDialog {

  final VoidCallback upgradeExceededDialog;
  final Function publicStorageUploadPage;

  UploadDialog({
    required this.upgradeExceededDialog,
    required this.publicStorageUploadPage
  });

  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  Future<void> galleryDialog() async {

    late String? fileBase64Encoded;

    final shortenText = ShortenText();

    final details = await PickerModel()
                      .galleryPicker(source: ImageSource.both);
    
    if(details == null) {
      return;
    }

    int countSelectedFiles = details.selectedFiles.length;

    if (countSelectedFiles == 0) {
      return;
    }
    
    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

    if(storageData.fileNamesList.length + countSelectedFiles > AccountPlan.mapFilesUpload[userData.accountType]!) {
      upgradeExceededDialog();
      return;
      
    }

    if(tempData.origin != OriginFile.public) {
      await CallNotify()
        .uploadingNotification(numberOfFiles: countSelectedFiles);
    }

    if(countSelectedFiles > 2) {
      SnakeAlert.uploadingSnake(
        snackState: scaffoldMessenger, 
        message: "Uploading $countSelectedFiles item(s)...");
    }

    for(var filesPath in details.selectedFiles) {

      final pathToString = filesPath.selectedFile.toString().
                            split(" ").last.replaceAll("'", "");
      
      final filesName = pathToString.split("/").last.replaceAll("'", "");
      final fileExtension = filesName.split('.').last;

      if (!Globals.supportedFileTypes.contains(fileExtension)) {
        CustomFormDialog.startDialog("Couldn't upload $filesName","File type is not supported.");
        await NotificationApi.stopNotification(0);
        continue;
      }

      if (storageData.fileNamesList.contains(filesName)) {
        CustomFormDialog.startDialog("Upload Failed", "$filesName already exists.");
        await NotificationApi.stopNotification(0);
        continue;
      } 

      if(countSelectedFiles < 2 && tempData.origin != OriginFile.public) {
        SnakeAlert.uploadingSnake(
          snackState: scaffoldMessenger, 
          message: "Uploading ${shortenText.cutText(filesName)}"); 
      }

      if (!(Globals.imageType.contains(fileExtension))) {
        final compressedFileByte = CompressorApi.compressFile(pathToString);
        fileBase64Encoded = base64.encode(compressedFileByte);
      } else {
        final filesBytes = File(pathToString).readAsBytesSync();
        fileBase64Encoded = base64.encode(filesBytes);
      }

      if (Globals.imageType.contains(fileExtension)) {

        List<int> bytes = await CompressorApi.compressedByteImage(path: pathToString, quality: 85);
        String compressedImageBase64Encoded = base64.encode(bytes);

        await UpdateListView().processUpdateListView(filePathVal: pathToString, selectedFileName: filesName, tableName: GlobalsTable.homeImage, fileBase64Encoded: compressedImageBase64Encoded);

      } else if (Globals.videoType.contains(fileExtension)) {

        final generatedThumbnail = await GenerateThumbnail(
          fileName: filesName, 
          filePath: pathToString
        ).generate();

        final thumbnailBytes = generatedThumbnail[0] as Uint8List;
        final thumbnailFile = generatedThumbnail[1] as File;

        await UpdateListView().processUpdateListView(
          filePathVal: pathToString, 
          selectedFileName: filesName, 
          tableName: GlobalsTable.homeVideo, 
          fileBase64Encoded: fileBase64Encoded,
          newFileToDisplay: thumbnailFile,
          thumbnailBytes: thumbnailBytes
        );

        await thumbnailFile.delete();

      }

      UpdateListView().addItemDetailsToListView(fileName: filesName);

      scaffoldMessenger.hideCurrentSnackBar();

      if(countSelectedFiles < 2) {

        SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${shortenText.cutText(filesName)} Has been added.");
        countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles) : null;

      }

    }

    await NotificationApi.stopNotification(0);

    if(countSelectedFiles >= 2) {

      SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${countSelectedFiles.toString()} Items has been added");
      countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles) : null;

    }

  }

  Future<void> filesDialog() async {

    late String? fileBase64;
    late File? newFileToDisplayPath;

    final shortenText = ShortenText();

    final resultPicker = await PickerModel().filePicker();
    if (resultPicker == null) {
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

    int countSelectedFiles = resultPicker.files.length;

    final uploadedPsFilesCount = psStorageData.psUploaderList.where((name) => name == userData.username).length;
    final allowedFileUploads = AccountPlan.mapFilesUpload[userData.accountType]!;

    if (tempData.origin == OriginFile.public && uploadedPsFilesCount > allowedFileUploads) {
      upgradeExceededDialog();
      return;

    } else if (tempData.origin != OriginFile.public && storageData.fileNamesList.length + countSelectedFiles > allowedFileUploads) {
      upgradeExceededDialog();
      return;
      
    }

    if(tempData.origin != OriginFile.public) {
      await CallNotify()
        .uploadingNotification(numberOfFiles: countSelectedFiles);
    }

    if(countSelectedFiles > 2) {
      SnakeAlert.uploadingSnake(
        snackState: scaffoldMessenger, 
        message: "Uploading $countSelectedFiles item(s)..."
      );
    } 

    for (final pickedFile in resultPicker.files) {

      final selectedFileName = pickedFile.name;
      final fileExtension = selectedFileName.split('.').last;

      if (!Globals.supportedFileTypes.contains(fileExtension)) {
        CustomFormDialog.startDialog("Couldn't upload $selectedFileName","File type is not supported.");
        await NotificationApi.stopNotification(0);

        if(tempData.origin == OriginFile.public) 
        { return; } else { continue; }

      }

      if (storageData.fileNamesList.contains(selectedFileName)) {
        CustomFormDialog.startDialog("Upload Failed", "$selectedFileName already exists.");
        await NotificationApi.stopNotification(0);

        if(tempData.origin == OriginFile.public) 
        { return; } else { continue; }

      }

      if(countSelectedFiles < 2 && tempData.origin != OriginFile.public) {
        SnakeAlert.uploadingSnake(
          snackState: scaffoldMessenger, 
          message: "Uploading ${shortenText.cutText(selectedFileName)}"
        );

      }

      final filePathVal = pickedFile.path.toString();

      if (!(Globals.imageType.contains(fileExtension))) {
        final compressedFileBytes = CompressorApi.compressFile(filePathVal);
        fileBase64 = base64.encode(compressedFileBytes);
      }

      if (Globals.imageType.contains(fileExtension)) {

        final compressQuality = tempData.origin 
          == OriginFile.public ? 71 : 85;

        List<int> bytes = await CompressorApi.compressedByteImage(path: filePathVal, quality: compressQuality);
        String compressedImageBase64Encoded = base64.encode(bytes);

        if(tempData.origin == OriginFile.public) {
          publicStorageUploadPage(filePathVal: filePathVal, fileName: selectedFileName, tableName: GlobalsTable.psImage, base64Encoded: compressedImageBase64Encoded);
          return;
        }

        await UpdateListView().processUpdateListView(
          filePathVal: filePathVal, 
          selectedFileName: selectedFileName, 
          tableName: GlobalsTable.homeImage, 
          fileBase64Encoded: compressedImageBase64Encoded
        );

      } else if (Globals.videoType.contains(fileExtension)) {

        final generatedThumbnail = await GenerateThumbnail(
          fileName: selectedFileName, 
          filePath: filePathVal
        ).generate();

        final thumbnailBytes = generatedThumbnail[0] as Uint8List;
        final thumbnailFile = generatedThumbnail[1] as File;

        newFileToDisplayPath = thumbnailFile;

        if(tempData.origin == OriginFile.public) {

          publicStorageUploadPage(
            filePathVal: filePathVal, fileName: selectedFileName, 
            tableName: GlobalsTable.psVideo, base64Encoded: fileBase64!,
            newFileToDisplay: newFileToDisplayPath, thumbnail: thumbnailBytes
          );

          return;

        }

        await UpdateListView().processUpdateListView(
          filePathVal: filePathVal, selectedFileName: selectedFileName, 
          tableName: GlobalsTable.homeVideo, fileBase64Encoded: fileBase64!, 
          newFileToDisplay: newFileToDisplayPath, thumbnailBytes: thumbnailBytes
        );

        await thumbnailFile.delete();

      } else {

        final getFileTable = tempData.origin == OriginFile.home 
          ? Globals.fileTypesToTableNames[fileExtension]! 
          : Globals.fileTypesToTableNamesPs[fileExtension]!;

        newFileToDisplayPath = await GetAssets().loadAssetsFile(Globals.fileTypeToAssets[fileExtension]!);

        if(tempData.origin == OriginFile.public) {
          publicStorageUploadPage(filePathVal: filePathVal, fileName: selectedFileName, tableName: getFileTable, base64Encoded: fileBase64!,newFileToDisplay: newFileToDisplayPath);
          return;
        }

        await UpdateListView().processUpdateListView(filePathVal: filePathVal, selectedFileName: selectedFileName,tableName: getFileTable,fileBase64Encoded: fileBase64!,newFileToDisplay: newFileToDisplayPath);
      }

      UpdateListView().addItemDetailsToListView(fileName: selectedFileName);

      scaffoldMessenger.hideCurrentSnackBar();

      if(countSelectedFiles < 2) {
        SnakeAlert.temporarySnake(snackState: scaffoldMessenger, message: "${shortenText.cutText(selectedFileName)} Has been added");
      }

    }

    if(countSelectedFiles > 2) {
      SnakeAlert.temporarySnake(
        snackState: scaffoldMessenger, 
        message: "${countSelectedFiles.toString()} Items has been added"
      );
    }

    await NotificationApi.stopNotification(0);

    if(countSelectedFiles > 0) {
      await CallNotify().uploadedNotification(title: "Upload Finished",count: countSelectedFiles);
    }

  }

  Future<void> foldersDialog() async {

    final folderPath = await FilePicker.platform.getDirectoryPath();

    if (folderPath == null) {
      return;
    }

    final folderName = path.basename(folderPath);

    if (storageData.foldersNameList.contains(folderName)) {
      CustomFormDialog.startDialog("Upload Failed", "$folderName already exists.");
      return;
    }

    await CallNotify().customNotification(title: "Uploading folder...", subMesssage: "${ShortenText().cutText(folderName)} In progress");

    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

    SnakeAlert.uploadingSnake(
      snackState: scaffoldMessenger, 
      message: "Uploading $folderName folder..."
    );

    final files = Directory(folderPath).listSync().whereType<File>().toList();

    if(files.length == AccountPlan.mapFilesUpload[userData.accountType]) {
      CustomFormDialog.startDialog("Couldn't upload $folderName", "It looks like the number of files in this folder exceeded the number of file you can upload. Please upgrade your account plan.");
      return;
    }

    await UpdateListView().insertFileDataFolder(
      folderPath: folderPath, 
      folderName: folderName, 
      files: files
    );

    await NotificationApi.stopNotification(0);

    scaffoldMessenger.hideCurrentSnackBar();

    SnakeAlert.temporarySnake(
      snackState: scaffoldMessenger,
      message: "Folder $folderName has been added"
    );

    await CallNotify().customNotification(title: "Folder Uploaded", subMesssage: "$folderName Has been added");

  }

}
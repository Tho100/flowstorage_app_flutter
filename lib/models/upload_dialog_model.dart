import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/generate_thumbnail.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/random_generator.dart';
import 'package:flowstorage_fsc/helper/scanner_pdf.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/models/offline_model.dart';
import 'package:flowstorage_fsc/models/picker_model.dart';
import 'package:flowstorage_fsc/models/update_list_view.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class UploadDialogModel {

  final VoidCallback upgradeExceededDialog;

  UploadDialogModel({
    required this.upgradeExceededDialog,
  });

  final storageData = GetIt.instance<StorageDataProvider>();

  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final userData = GetIt.instance<UserDataProvider>();

  Future<void> _saveOfflineFile({
    required String fileName, 
    required Uint8List fileData,
    Uint8List? videoThumbnail
  }) async {

    await OfflineModel().saveOfflineFile(fileName: fileName, fileData: fileData);

    if(videoThumbnail == null || videoThumbnail.isEmpty) {
      storageData.imageBytesList.add(fileData);
      storageData.imageBytesFilteredList.add(fileData);

    } else {
      storageData.imageBytesList.add(videoThumbnail);
      storageData.imageBytesFilteredList.add(videoThumbnail);

    }

    tempStorageData.addOfflineFileName(fileName);

  }

  Future<void> galleryDialog() async {

    final details = await PickerModel().galleryPicker(
      source: ImageSource.both, 
      isFromSelectProfilePic: false
    );
    
    if(details == null) {
      return;
    }

    final countSelectedFiles = details.selectedFiles.length;

    if (countSelectedFiles == 0) {
      return;
    }
    
    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

    if(tempData.origin != OriginFile.offline) {

      final isFilesMaxUpload = storageData.fileNamesList.length + countSelectedFiles > AccountPlan.mapFilesUpload[userData.accountType]!;

      if(isFilesMaxUpload) {
        upgradeExceededDialog();
        return;
      }

    } 

    if(tempData.origin != OriginFile.public) {
      await CallNotify()
        .uploadingNotification(numberOfFiles: countSelectedFiles);
    }

    if(countSelectedFiles > 2) {
      SnackAlert.uploadingSnack(
        snackState: scaffoldMessenger, 
        message: "Uploading $countSelectedFiles item(s)..."
      );
    }

    for(final filesPath in details.selectedFiles) {

      final filePath = filesPath.selectedFile.toString()
        .split(" ").last.replaceAll("'", "");
      
      final fileName = filePath.split("/")
        .last.replaceAll("'", "");

      final fileType = fileName.split('.').last;

      if (!Globals.supportedFileTypes.contains(fileType)) {
        CustomFormDialog.startDialog("Couldn't upload $fileName", "File type is not supported.");
        await NotificationApi.stopNotification(0);
        continue;
      }

      if (storageData.fileNamesList.contains(fileName)) {
        CustomFormDialog.startDialog("Upload Failed", "$fileName already exists.");
        await NotificationApi.stopNotification(0);
        continue;
      } 

      if(countSelectedFiles < 2 && tempData.origin != OriginFile.public) {
        SnackAlert.uploadingSnack(
          snackState: scaffoldMessenger, 
          message: "Uploading $fileName"
        ); 
      }

      final fileBase64Encoded = Globals.imageType.contains(fileType)
        ? base64.encode(await File(filePath).readAsBytes())
        : base64.encode(await CompressorApi.compressFile(filePath));

      if (Globals.imageType.contains(fileType)) {

        final compressedImageBytes = await CompressorApi
          .compressedByteImage(path: filePath, quality: 80);

        final compressedImageBase64Encoded = base64.encode(compressedImageBytes);

        if(tempData.origin == OriginFile.offline) {
          final decodeToBytes = base64.decode(compressedImageBase64Encoded);
          final imageBytes = Uint8List.fromList(decodeToBytes);

          await _saveOfflineFile(fileName: fileName, fileData: imageBytes);

        } else {
          await UpdateListView()
            .processUpdateListView(filePath: filePath, fileName: fileName, tableName: GlobalsTable.homeImage, fileBase64Encoded: compressedImageBase64Encoded);

        }

      } else if (Globals.videoType.contains(fileType)) {

        final generatedThumbnail = await GenerateThumbnail(
          fileName: fileName, 
          filePath: filePath
        ).generate();

        final thumbnailBytes = generatedThumbnail[0] as Uint8List;
        final thumbnailFile = generatedThumbnail[1] as File;

        if(tempData.origin == OriginFile.offline) {
          final fileData = base64.decode(fileBase64Encoded);
          await _saveOfflineFile(fileName: fileName, fileData: fileData, videoThumbnail: thumbnailBytes);

        } else {
          await UpdateListView()
            .processUpdateListView(filePath: filePath, fileName: fileName, tableName: GlobalsTable.homeVideo, fileBase64Encoded: fileBase64Encoded, newFileToDisplay: thumbnailFile,thumbnailBytes: thumbnailBytes);

        }

        await thumbnailFile.delete();

      }

      UpdateListView().addItemDetailsToListView(fileName: fileName);

      scaffoldMessenger.hideCurrentSnackBar();

      if(countSelectedFiles < 2) {

        SnackAlert.temporarySnack(
          snackState: scaffoldMessenger, 
          message: "Added $fileName"
        );

        countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles) : null;

      }

    }

    await NotificationApi.stopNotification(0);

    if(countSelectedFiles >= 2) {

      SnackAlert.temporarySnack(
        snackState: scaffoldMessenger, 
        message: "Added ${countSelectedFiles.toString()} item(s)."
      );

      countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles) : null;

    }

  }

  Future<void> filesDialog(Function publicStorageUploadPage) async {

    late String? fileBase64;

    final resultPicker = await PickerModel().filePicker();

    if (resultPicker == null) {
      return;
    }

    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

    final countSelectedFiles = resultPicker.files.length;

    final uploadedPsFilesCount = tempData.psTotalUpload;
    final allowedFileUploads = AccountPlan.mapFilesUpload[userData.accountType]!;

    final isFilesMaxUpload = (tempData.origin != OriginFile.public && tempData.origin != OriginFile.offline) && storageData.fileNamesList.length + countSelectedFiles > allowedFileUploads;
    final isPsMaxUpload = tempData.origin == OriginFile.public && uploadedPsFilesCount > allowedFileUploads;

    if (isFilesMaxUpload || isPsMaxUpload) {
      upgradeExceededDialog();
      return;
    } 

    if(tempData.origin != OriginFile.public && tempData.origin != OriginFile.offline) {
      await CallNotify()
        .uploadingNotification(numberOfFiles: countSelectedFiles);
    }

    if(countSelectedFiles > 2) {
      SnackAlert.uploadingSnack(
        snackState: scaffoldMessenger, 
        message: "Uploading $countSelectedFiles item(s)..."
      );
    } 

    for (final pickedFile in resultPicker.files) {
      
      final fileName = pickedFile.name;
      final fileType = fileName.split('.').last;

      if (!Globals.supportedFileTypes.contains(fileType)) {
        CustomFormDialog.startDialog("Couldn't upload $fileName","File type is not supported.");
        await NotificationApi.stopNotification(0);

        if(tempData.origin == OriginFile.public) 
        { return; } else { continue; }

      }

      if (storageData.fileNamesList.contains(fileName)) {
        CustomFormDialog.startDialog("Upload Failed", "$fileName already exists.");
        await NotificationApi.stopNotification(0);

        if(tempData.origin == OriginFile.public) 
        { return; } else { continue; }

      }

      if(countSelectedFiles < 2 && tempData.origin != OriginFile.public) {
        SnackAlert.uploadingSnack(
          snackState: scaffoldMessenger, 
          message: "Uploading $fileName"
        );
      }

      final filePath = pickedFile.path.toString();
      
      if (!(Globals.imageType.contains(fileType))) {
        final compressedFileBytes = await CompressorApi.compressFile(filePath);
        fileBase64 = base64.encode(compressedFileBytes); 
      }

      if (Globals.imageType.contains(fileType)) {

        final compressQuality = tempData.origin == OriginFile.public 
          ? 71 : 80;

        final compressedImageBytes = await CompressorApi
          .compressedByteImage(path: filePath, quality: compressQuality);

        final compressedImageBase64Encoded = base64.encode(compressedImageBytes);

        if(tempData.origin == OriginFile.public) {
          publicStorageUploadPage(filePath: filePath, fileName: fileName, tableName: GlobalsTable.psImage, base64Encoded: compressedImageBase64Encoded);
          return;
        }

        if(tempData.origin == OriginFile.offline) {
          final decodeToBytes = base64.decode(compressedImageBase64Encoded);
          final imageBytes = Uint8List.fromList(decodeToBytes);

          await _saveOfflineFile(fileName: fileName, fileData: imageBytes);

        } else {
          await UpdateListView()
            .processUpdateListView(filePath: filePath, fileName: fileName, tableName: GlobalsTable.homeImage, fileBase64Encoded: compressedImageBase64Encoded);

        }

      } else if (Globals.videoType.contains(fileType)) {

        final generatedThumbnail = await GenerateThumbnail(
          fileName: fileName, 
          filePath: filePath
        ).generate();

        final thumbnailBytes = generatedThumbnail[0] as Uint8List;
        final thumbnailFile = generatedThumbnail[1] as File;

        if(tempData.origin == OriginFile.public) {
          publicStorageUploadPage(filePath: filePath, fileName: fileName, tableName: GlobalsTable.psVideo, base64Encoded: fileBase64!, previewData: thumbnailFile, thumbnail: thumbnailBytes);
          return;
        }

        if(tempData.origin == OriginFile.offline) {
          final fileData = base64.decode(fileBase64!);
          await _saveOfflineFile(fileName: fileName, fileData: fileData, videoThumbnail: thumbnailBytes);

        } else {
          await UpdateListView()
            .processUpdateListView(filePath: filePath, fileName: fileName, tableName: GlobalsTable.homeVideo, fileBase64Encoded: fileBase64!, newFileToDisplay: thumbnailFile, thumbnailBytes: thumbnailBytes);

        }

        await thumbnailFile.delete();

      } else {

        final getFileTable = tempData.origin == OriginFile.home 
          ? Globals.fileTypesToTableNames[fileType]! 
          : Globals.fileTypesToTableNamesPs[fileType]!;

        final assetsPreviewImage = await GetAssets()
          .loadAssetsFile(Globals.fileTypeToAssets[fileType]!);

        if(tempData.origin == OriginFile.public) {
          publicStorageUploadPage(filePath: filePath, fileName: fileName, tableName: getFileTable, base64Encoded: fileBase64!, previewData: assetsPreviewImage);
          return;
        }

        await UpdateListView()
          .processUpdateListView(filePath: filePath, fileName: fileName, tableName: getFileTable, fileBase64Encoded: fileBase64!, newFileToDisplay: assetsPreviewImage);

        if(tempData.origin == OriginFile.offline) {
          tempStorageData.addOfflineFileName(fileName);
        }

      }

      UpdateListView().addItemDetailsToListView(fileName: fileName);

      scaffoldMessenger.hideCurrentSnackBar();

      if(countSelectedFiles < 2) {
        SnackAlert.temporarySnack(
          snackState: scaffoldMessenger, 
          message: "Added $fileName"
        );
      }

    }

    if(countSelectedFiles > 2) {
      SnackAlert.temporarySnack(
        snackState: scaffoldMessenger, 
        message: "Added ${countSelectedFiles.toString()} item(s)."
      );
    }

    await NotificationApi.stopNotification(0);

    if(countSelectedFiles > 0) {
      await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles);
    }

  }

  Future<void> foldersDialog() async {

    final folderPath = await FilePicker.platform.getDirectoryPath();

    if (folderPath == null) {
      return;
    }

    final folderName = path.basename(folderPath);

    if (tempStorageData.folderNameList.contains(folderName)) {
      CustomFormDialog.startDialog("Upload Failed", "$folderName already exists.");
      return;
    }

    await CallNotify().customNotification(title: "Uploading folder...", subMessage: "${ShortenText().cutText(folderName)} In progress");

    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

    SnackAlert.uploadingSnack(
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

    SnackAlert.temporarySnack(
      snackState: scaffoldMessenger,
      message: "Added $folderName folder."
    );

    await CallNotify().customNotification(title: "Folder Uploaded", subMessage: "Folder $folderName has been added");

  }

  Future<void> scannerUpload() async {
    
    final scannerPdf = ScannerPdf();

    final imagePath = await CunningDocumentScanner.getPictures();

    if(imagePath!.isEmpty) {
      return;
    }

    final generateFileName = Generator.generateRandomString(Generator.generateRandomInt(5,15));

    await CallNotify().customNotification(title: "Uploading...",subMessage: "1 File(s) in progress") ;
    
    for(final images in imagePath) {

      File compressedDocImage = await CompressorApi
        .processImageCompression(path: images, quality: 65); 

      await scannerPdf.convertImageToPdf(imagePath: compressedDocImage);
      
    }

    await scannerPdf.savePdf(fileName: generateFileName);

    final fileNameWithExtension = "$generateFileName.pdf";

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileNameWithExtension');

    final compressedBytes = await CompressorApi.compressFile(file.path.toString());

    final toBase64Encoded = base64.encode(compressedBytes);

    final newFileToDisplay = await GetAssets().loadAssetsFile("pdf0.jpg");

    if (tempData.origin == OriginFile.offline) {
      final decodeToBytes = await GetAssets().loadAssetsData("pdf0.jpg");

      final imageBytes = Uint8List.fromList(decodeToBytes);
      final fileData = base64.decode(toBase64Encoded);

      await _saveOfflineFile(fileName: fileNameWithExtension, fileData: fileData, videoThumbnail: imageBytes);

    } else {
      await UpdateListView()
        .processUpdateListView(filePath: file.path, fileName: fileNameWithExtension, tableName: GlobalsTable.homePdf, fileBase64Encoded: toBase64Encoded, newFileToDisplay: newFileToDisplay);

    }

    UpdateListView().addItemDetailsToListView(fileName: fileNameWithExtension);

    await file.delete();

    await NotificationApi.stopNotification(0);

    SnackAlert.okSnack(message: "Added $fileNameWithExtension", icon: Icons.check);

    await CallNotify().uploadedNotification(title: "Upload Finished", count: 1);

  }

  Future<void> photoUpload() async {

    final details = await PickerModel().galleryPicker(
      source: ImageSource.camera, 
      isFromSelectProfilePic: false
    );

    if (details!.selectedFiles.isEmpty) {
      return;
    }

    for(final photoTaken in details.selectedFiles) {

      final imagePath = photoTaken.selectedFile.toString()
        .split(" ").last.replaceAll("'", "");

      final imageName = imagePath.split("/")
        .last.replaceAll("'", "");

      final fileType = imageName.split('.').last;

      if(!(Globals.imageType.contains(fileType))) {
        CustomFormDialog.startDialog("Couldn't upload photo","File type is not supported.");
        return;
      }

      final compressedImageBytes = await CompressorApi
        .compressedByteImage(path: imagePath, quality: 78);
    
      final imageBase64Encoded = base64.encode(compressedImageBytes); 

      if(storageData.fileNamesList.contains(imageName)) {
        CustomFormDialog.startDialog("Upload Failed", "$imageName already exists.");
        return;
      }

      if (tempData.origin == OriginFile.offline) {
        final decodeToBytes = base64.decode(imageBase64Encoded);
        final imageBytes = Uint8List.fromList(decodeToBytes);
        
        await _saveOfflineFile(fileName: imageName, fileData: imageBytes);

      } else {
        await UpdateListView()
          .processUpdateListView(filePath: imagePath, fileName: imageName, tableName: GlobalsTable.homeImage, fileBase64Encoded: imageBase64Encoded);
        
      }

      UpdateListView().addItemDetailsToListView(fileName: imageName);

      await File(imagePath).delete();

    }

    SnackAlert.okSnack(message: "Added 1 photo.", icon: Icons.check);

    await CallNotify().uploadedNotification(title: "Upload Finished",count: 1);
    
  }

  Future<void> intentShareUpload({
    required String fileName,
    required String filePath
  }) async {
    
    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

    await CallNotify()
      .uploadingNotification(numberOfFiles: 1);

    SnackAlert.uploadingSnack(
      snackState: scaffoldMessenger, 
      message: "Uploading $fileName"
    );

    final fileType = fileName.split('.').last;

    String? fileBase64Encoded;

    if (!(Globals.imageType.contains(fileType))) {
      final compressedFileByte = await CompressorApi.compressFile(filePath);
      fileBase64Encoded = base64.encode(compressedFileByte);

    } else {
      final filesBytes = await File(filePath).readAsBytes();
      fileBase64Encoded = base64.encode(filesBytes);

    }

    if (Globals.imageType.contains(fileType)) {

      final compressedImageBytes = await CompressorApi
        .compressedByteImage(path: filePath, quality: 80);

      final compressedImageBase64Encoded = base64.encode(compressedImageBytes);

      await UpdateListView()
        .processUpdateListView(filePath: filePath, fileName: fileName, tableName: GlobalsTable.homeImage, fileBase64Encoded: compressedImageBase64Encoded);

    } else if (Globals.videoType.contains(fileType)) {

      final generatedThumbnail = await GenerateThumbnail(
        fileName: fileName, 
        filePath: filePath
      ).generate();

      final thumbnailBytes = generatedThumbnail[0] as Uint8List;
      final thumbnailFile = generatedThumbnail[1] as File;

      await UpdateListView()
        .processUpdateListView(filePath: filePath, fileName: fileName, tableName: GlobalsTable.homeVideo, fileBase64Encoded: fileBase64Encoded, newFileToDisplay: thumbnailFile, thumbnailBytes: thumbnailBytes);

      await thumbnailFile.delete();

    } else {

      final getFileTable = Globals.fileTypesToTableNames[fileType]!;

      final imagePreview = await GetAssets()
        .loadAssetsFile(Globals.fileTypeToAssets[fileType]!);

      await UpdateListView()
        .processUpdateListView(filePath: filePath, fileName: fileName, tableName: getFileTable,fileBase64Encoded: fileBase64Encoded, newFileToDisplay: imagePreview);
      
    }

    UpdateListView().addItemDetailsToListView(fileName: fileName);
    
    scaffoldMessenger.hideCurrentSnackBar();

    await NotificationApi.stopNotification(0);

    SnackAlert.temporarySnack(
      snackState: scaffoldMessenger, 
      message: "Added $fileName"
    );

    await CallNotify().
      uploadedNotification(title: "Upload Finished", count: 1);

  }

}
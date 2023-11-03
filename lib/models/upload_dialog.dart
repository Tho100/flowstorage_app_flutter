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
import 'package:flowstorage_fsc/models/offline_mode.dart';
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
import 'package:path_provider/path_provider.dart';

class UploadDialog {

  final VoidCallback upgradeExceededDialog;

  UploadDialog({
    required this.upgradeExceededDialog,
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
        final compressedFileByte = await CompressorApi.compressFile(pathToString);
        fileBase64Encoded = base64.encode(compressedFileByte);
      } else {
        final filesBytes = await File(pathToString).readAsBytes();
        fileBase64Encoded = base64.encode(filesBytes);
      }

      if (Globals.imageType.contains(fileExtension)) {

        List<int> bytes = await CompressorApi.compressedByteImage(path: pathToString, quality: 80);
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

        SnakeAlert.temporarySnake(
          snackState: scaffoldMessenger, 
          message: "${shortenText.cutText(filesName)} Has been added."
        );

        countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles) : null;

      }

    }

    await NotificationApi.stopNotification(0);

    if(countSelectedFiles >= 2) {

      SnakeAlert.temporarySnake(
        snackState: scaffoldMessenger, 
        message: "${countSelectedFiles.toString()} Items has been added"
      );

      countSelectedFiles > 0 ? await CallNotify().uploadedNotification(title: "Upload Finished", count: countSelectedFiles) : null;

    }

  }

  Future<void> filesDialog(Function publicStorageUploadPage) async {

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

    if(tempData.origin != OriginFile.public && tempData.origin != OriginFile.offline) {
      await CallNotify()
        .uploadingNotification(numberOfFiles: countSelectedFiles);
    }

    if(countSelectedFiles > 2) {
      SnakeAlert.uploadingSnake(
        snackState: scaffoldMessenger, 
        message: "Uploading $countSelectedFiles item(s)..."
      );
    } 

    final fileTypes = resultPicker.names.map((name) => name!.split('.').last).toList();

    if(tempData.origin == OriginFile.offline && fileTypes.any((type) => Globals.imageType.contains(type))) {

      for(var item in resultPicker.files) {

        final filePath = item.path.toString();
        final fileName = item.name;

        final compressQuality = tempData.origin 
            == OriginFile.public ? 71 : 80;

        List<int> bytes = await CompressorApi.compressedByteImage(path: filePath, quality: compressQuality);
        String compressedImageBase64Encoded = base64.encode(bytes);

        final decodeToBytes = base64.decode(compressedImageBase64Encoded);
        final imageBytes = Uint8List.fromList(decodeToBytes);
        await OfflineMode().saveOfflineFile(fileName: fileName, fileData: imageBytes);

        UpdateListView().addItemDetailsToListView(fileName: fileName);

        storageData.imageBytesList.add(imageBytes);
        storageData.imageBytesFilteredList.add(imageBytes);

        scaffoldMessenger.hideCurrentSnackBar();

        SnakeAlert.temporarySnake(
          snackState: scaffoldMessenger, 
          message: "${shortenText.cutText(fileName)} Has been added"
        );
      
      }

      return;

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

      final filePath = pickedFile.path.toString();

      if (!(Globals.imageType.contains(fileExtension))) {
        final compressedFileBytes = await CompressorApi.compressFile(filePath);
        fileBase64 = base64.encode(compressedFileBytes);
      }

      if (Globals.imageType.contains(fileExtension)) {

        final compressQuality = tempData.origin 
            == OriginFile.public ? 71 : 80;

        List<int> bytes = await CompressorApi.compressedByteImage(path: filePath, quality: compressQuality);
        String compressedImageBase64Encoded = base64.encode(bytes);

        if(tempData.origin == OriginFile.public) {
          publicStorageUploadPage(filePath: filePath, fileName: selectedFileName, tableName: GlobalsTable.psImage, base64Encoded: compressedImageBase64Encoded);
          return;
        }

        await UpdateListView().processUpdateListView(
          filePathVal: filePath, 
          selectedFileName: selectedFileName, 
          tableName: GlobalsTable.homeImage, 
          fileBase64Encoded: compressedImageBase64Encoded
        );

      } else if (Globals.videoType.contains(fileExtension)) {

        final generatedThumbnail = await GenerateThumbnail(
          fileName: selectedFileName, 
          filePath: filePath
        ).generate();

        final thumbnailBytes = generatedThumbnail[0] as Uint8List;
        final thumbnailFile = generatedThumbnail[1] as File;

        newFileToDisplayPath = thumbnailFile;

        if(tempData.origin == OriginFile.public) {

          publicStorageUploadPage(
            filePath: filePath, fileName: selectedFileName, 
            tableName: GlobalsTable.psVideo, base64Encoded: fileBase64!,
            previewData: newFileToDisplayPath, thumbnail: thumbnailBytes
          );

          return;

        }

        await UpdateListView().processUpdateListView(
          filePathVal: filePath, selectedFileName: selectedFileName, 
          tableName: GlobalsTable.homeVideo, fileBase64Encoded: fileBase64!, 
          newFileToDisplay: newFileToDisplayPath, thumbnailBytes: thumbnailBytes
        );

        await thumbnailFile.delete();

      } else {

        final getFileTable = tempData.origin == OriginFile.home 
          ? Globals.fileTypesToTableNames[fileExtension]! 
          : Globals.fileTypesToTableNamesPs[fileExtension]!;

        newFileToDisplayPath = await GetAssets()
          .loadAssetsFile(Globals.fileTypeToAssets[fileExtension]!);

        if(tempData.origin == OriginFile.public) {
          publicStorageUploadPage(
            filePath: filePath, fileName: selectedFileName, 
            tableName: getFileTable, base64Encoded: fileBase64!, 
            previewData: newFileToDisplayPath);
          return;
        }

        await UpdateListView().processUpdateListView(filePathVal: filePath, selectedFileName: selectedFileName,tableName: getFileTable,fileBase64Encoded: fileBase64!,newFileToDisplay: newFileToDisplayPath);

      }

      UpdateListView().addItemDetailsToListView(fileName: selectedFileName);

      scaffoldMessenger.hideCurrentSnackBar();

      if(countSelectedFiles < 2) {
        SnakeAlert.temporarySnake(
          snackState: scaffoldMessenger, 
          message: "${shortenText.cutText(selectedFileName)} Has been added"
        );
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

  Future<void> scannerUpload() async {
    
    final scannerPdf = ScannerPdf();

    final imagePath = await CunningDocumentScanner.getPictures();

    if(imagePath!.isEmpty) {
      return;
    }

    final generateFileName = Generator.generateRandomString(Generator.generateRandomInt(5,15));

    await CallNotify().customNotification(title: "Uploading...",subMesssage: "1 File(s) in progress") ;
    
    for(var images in imagePath) {

      File compressedDocImage = await CompressorApi.processImageCompression(path: images,quality: 65); 
      await scannerPdf.convertImageToPdf(imagePath: compressedDocImage);
      
    }

    await scannerPdf.savePdf(fileName: generateFileName);

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$generateFileName.pdf');

    final compressedBytes = await CompressorApi.compressFile(file.path.toString());
    final toBase64Encoded = base64.encode(compressedBytes);
    final newFileToDisplay = await GetAssets().loadAssetsFile("pdf0.jpg");

    if (tempData.origin == OriginFile.offline) {

      final decodeToBytes = await GetAssets().loadAssetsData("pdf0.jpg");
      final imageBytes = Uint8List.fromList(decodeToBytes);
      final decodedBase64String = base64.decode(toBase64Encoded);

      await OfflineMode().saveOfflineFile(fileName: "$generateFileName.pdf", fileData: decodedBase64String);

      storageData.imageBytesFilteredList.add(imageBytes);
      storageData.imageBytesList.add(imageBytes);

    } else {
      
      await UpdateListView().processUpdateListView(
        filePathVal: file.path,
        selectedFileName: "$generateFileName.pdf",
        tableName: GlobalsTable.homePdf, 
        fileBase64Encoded: toBase64Encoded,
        newFileToDisplay: newFileToDisplay
      );

    }

    UpdateListView().addItemDetailsToListView(fileName: "$generateFileName.pdf");

    await file.delete();

    await NotificationApi.stopNotification(0);

    SnakeAlert.okSnake(message: "$generateFileName.pdf Has been added",icon: Icons.check);

    await CallNotify().uploadedNotification(title: "Upload Finished", count: 1);

  }

  Future<void> photoUpload() async {

    final details = await PickerModel()
                        .galleryPicker(source: ImageSource.camera);

    if (details!.selectedFiles.isEmpty) {
      return;
    }

    for(var photoTaken in details.selectedFiles) {

      final imagePath = photoTaken.selectedFile.toString()
                        .split(" ").last.replaceAll("'", "");

      final imageName = imagePath.split("/").last.replaceAll("'", "");
      final fileExtension = imageName.split('.').last;

      if(!(Globals.imageType.contains(fileExtension))) {
        CustomFormDialog.startDialog("Couldn't upload photo","File type is not supported.");
        return;
      }

      List<int> bytes = await CompressorApi.compressedByteImage(path: imagePath, quality: 78);
    
      final imageBase64Encoded = base64.encode(bytes); 

      if(storageData.fileNamesList.contains(imageName)) {
        CustomFormDialog.startDialog("Upload Failed", "$imageName already exists.");
        return;
      }

      if (tempData.origin == OriginFile.offline) {

        final decodeToBytes = base64.decode(imageBase64Encoded);
        final imageBytes = Uint8List.fromList(decodeToBytes);
        await OfflineMode().saveOfflineFile(fileName: imageName, fileData: imageBytes);

        storageData.imageBytesFilteredList.add(decodeToBytes);
        storageData.imageBytesList.add(decodeToBytes);

      } else {

        await UpdateListView().processUpdateListView(
          filePathVal: imagePath, 
          selectedFileName: imageName, 
          tableName: GlobalsTable.homeImage, 
          fileBase64Encoded: imageBase64Encoded
        );
        
      }

      UpdateListView().addItemDetailsToListView(fileName: imageName);

      await File(imagePath).delete();

    }

    SnakeAlert.okSnake(message: "1 photo has been added", icon: Icons.check);

    await CallNotify().uploadedNotification(title: "Upload Finished",count: 1);
    
  }

  Future<void> intentShareUpload({
    required String fileName,
    required String filePath
  }) async {
    
    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

    await CallNotify()
      .uploadingNotification(numberOfFiles: 1);

    SnakeAlert.uploadingSnake(
      snackState: scaffoldMessenger, 
      message: "Uploading ${ShortenText().cutText(fileName)}...");

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

      List<int> bytes = await CompressorApi.compressedByteImage(path: filePath, quality: 80);
      String compressedImageBase64Encoded = base64.encode(bytes);

      await UpdateListView().processUpdateListView(filePathVal: filePath, selectedFileName: fileName, tableName: GlobalsTable.homeImage, fileBase64Encoded: compressedImageBase64Encoded);

    } else if (Globals.videoType.contains(fileType)) {

      final generatedThumbnail = await GenerateThumbnail(
        fileName: fileName, 
        filePath: filePath
      ).generate();

      final thumbnailBytes = generatedThumbnail[0] as Uint8List;
      final thumbnailFile = generatedThumbnail[1] as File;

      await UpdateListView().processUpdateListView(
        filePathVal: filePath, 
        selectedFileName: fileName, 
        tableName: GlobalsTable.homeVideo, 
        fileBase64Encoded: fileBase64Encoded,
        newFileToDisplay: thumbnailFile,
        thumbnailBytes: thumbnailBytes
      );

      await thumbnailFile.delete();

    } else {

      final getFileTable = Globals.fileTypesToTableNames[fileType]!;

      final imagePreview = await GetAssets()
            .loadAssetsFile(Globals.fileTypeToAssets[fileType]!);

      await UpdateListView().processUpdateListView(filePathVal: filePath, selectedFileName: fileName, tableName: getFileTable,fileBase64Encoded: fileBase64Encoded, newFileToDisplay: imagePreview);
      
    }

    UpdateListView().addItemDetailsToListView(fileName: fileName);
    
    scaffoldMessenger.hideCurrentSnackBar();

    await NotificationApi.stopNotification(0);

    SnakeAlert.temporarySnake(
      snackState: scaffoldMessenger, 
      message: "${ShortenText().cutText(fileName)} Has been added."
    );

    await CallNotify().
      uploadedNotification(title: "Upload Finished", count: 1);

  }

}
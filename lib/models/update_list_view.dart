import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_query/insert_data.dart';
import 'package:flowstorage_fsc/folder_query/create_folder.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/generate_thumbnail.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:path/path.dart' as path;
import 'package:get_it/get_it.dart';

class UpdateListView {

  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final userData = GetIt.instance<UserDataProvider>();

  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();

  final insertData = InsertData();

  void addItemDetailsToListView({required String fileName}) {
    storageData.fileDateFilteredList.add("Just now");
    storageData.fileDateList.add("Just now");
    storageData.fileNamesList.add(fileName);
    storageData.fileNamesFilteredList.add(fileName);
  }

  Future<void> _insertFileData({
    required String table,
    required String filePath,
    required dynamic fileValue,
    dynamic vidThumbnail,
  }) async {

    List<Future<void>> isolatedFileFutures = [];

    isolatedFileFutures.add(insertData.insertValueParams(
      tableName: table,
      fileName: filePath,
      userName: userData.username,
      fileValue: fileValue,
      videoThumbnail: vidThumbnail,
    ));

    await Future.wait(isolatedFileFutures);
  }

  Future<void> insertFileDataFolder({
    required String folderPath, 
    required String folderName,
    required List<File> files
    }) async {

    final fileTypes = <String>[];
    final videoThumbnails = <String>[];
    final fileNames = <String>[];
    final fileValues = <String>[];

    for (final folderFile in files) {

      final getFileName = path.basename(folderFile.path);
      final getExtension = getFileName.split('.').last;

      if (Globals.videoType.contains(getExtension)) {
        final generatedThumbnail = await GenerateThumbnail(
          fileName: getFileName, 
          filePath: folderFile.path
        ).generate();

        final thumbnailBytes = generatedThumbnail[0] as Uint8List;
        final thumbnailBase64 = base64.encode(thumbnailBytes);

        videoThumbnails.add(thumbnailBase64);

        final compressedFileData = await CompressorApi.compressFile(folderFile.path);
        final base64encoded = base64.encode(compressedFileData);
        
        fileValues.add(base64encoded);

      } else if (Globals.imageType.contains(getExtension)) {
        final compressedImage = await CompressorApi
          .compressedByteImage(path: folderFile.path, quality: 85);

        final base64Encoded = base64.encode(compressedImage);
        fileValues.add(base64Encoded);

      } else if (Globals.generalFileTypes.contains(getExtension)) {
        final compressedFileData = await CompressorApi.compressFile(folderFile.path.toString());
        final base64encoded = base64.encode(compressedFileData);
        fileValues.add(base64encoded);

      }

      fileTypes.add(getExtension);
      fileNames.add(getFileName);
      
    }

    await CreateFolder(
      titleFolder: folderName,
      fileValues: fileValues,
      fileNames: fileNames,
      fileTypes: fileTypes,
      videoThumbnail: videoThumbnails,
    ).create();

    tempStorageData.folderNameList.add(folderName);
    
  }

  Future<void> processUpdateListView({
    required String filePathVal,
    required String selectedFileName,
    required String tableName,
    required String fileBase64Encoded,
    File? newFileToDisplay,
    dynamic thumbnailBytes,
  }) async {

    List<Uint8List> newImageByteValues = [];
    List<Uint8List> newFilteredSearchedBytes = [];

    final verifyTableName = tempData.origin == OriginFile.directory ? GlobalsTable.directoryUploadTable : tableName;

    if (tempData.origin != OriginFile.offline) {
      await _insertFileData(table: verifyTableName, filePath: selectedFileName, fileValue: fileBase64Encoded, vidThumbnail: thumbnailBytes);

    } else {
      final fileByteData = base64.decode(fileBase64Encoded);
      await OfflineMode().processSaveOfflineFile(fileName: selectedFileName, fileData: fileByteData);

    }

    final isHomeImageOrPsImage = tableName == GlobalsTable.homeImage || tableName == GlobalsTable.psImage;
    final fileToDisplay = newFileToDisplay;

    if (isHomeImageOrPsImage) {
      newImageByteValues.add(File(filePathVal).readAsBytesSync());
      newFilteredSearchedBytes.add(File(filePathVal).readAsBytesSync());
      
    } else {
      newImageByteValues.add(fileToDisplay!.readAsBytesSync());
      newFilteredSearchedBytes.add(fileToDisplay.readAsBytesSync());

    }

    final homeImageData = storageData.homeImageBytesList;
    final homeThumbnailData = storageData.homeThumbnailBytesList;

    if (verifyTableName == GlobalsTable.homeImage) {
      homeImageData.addAll(newFilteredSearchedBytes);
      
    } else if (verifyTableName == GlobalsTable.homeVideo) {
      homeThumbnailData.add(thumbnailBytes);

    } else if (verifyTableName == GlobalsTable.psImage) {
      psStorageData.psImageBytesList.addAll(newFilteredSearchedBytes);
      psStorageData.myPsImageBytesList.addAll(newFilteredSearchedBytes);

    } else if (verifyTableName == GlobalsTable.psVideo) {
      psStorageData.psThumbnailBytesList.add(thumbnailBytes);
      psStorageData.myPsThumbnailBytesList.add(thumbnailBytes);

    }

    storageData.updateImageBytes(newImageByteValues);
    storageData.updateFilteredImageBytes(newFilteredSearchedBytes);

  }
}
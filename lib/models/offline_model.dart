import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class OfflineModel {

  late Directory offlineDirs;

  OfflineModel() {
    initializeOfflineDirs();
  }

  Future<Directory> returnOfflinePath() async {
    final getDirApplication = await getApplicationDocumentsDirectory();
    offlineDirs = Directory('${getDirApplication.path}/offline_files');
    return offlineDirs;
  }

  Future<void> initializeOfflineDirs() async {
    final getDirApplication = await getApplicationDocumentsDirectory();
    offlineDirs = Directory('${getDirApplication.path}/offline_files');
  }

  Future<void> init() async {
    await initializeOfflineDirs();
  }

  Future<void> deleteFile(String fileName) async {
    
    await init();

    final file = File('${offlineDirs.path}/$fileName');
    file.deleteSync();

  }

  Future<void> renameFile(String fileName, String newFileName) async {

    await init();

    final file = File('${offlineDirs.path}/$fileName');
    final newPath = '${offlineDirs.path}/$newFileName';

    await file.rename(newPath);

  }

  Future<void> saveOfflineFile({
    required String fileName, 
    required Uint8List fileData
  }) async {

    final getDirApplication = await getApplicationDocumentsDirectory();
    final offlineDirPath = Directory('${getDirApplication.path}/offline_files');

    if(!offlineDirPath.existsSync()) {
      offlineDirPath.createSync();
      final setupFiles = File('${offlineDirPath.path}/$fileName');
      await setupFiles.writeAsBytes(fileData);

    } else {
      final setupFiles = File('${offlineDirPath.path}/$fileName');
      await setupFiles.writeAsBytes(fileData);

    }
     
  }

  void saveOfflineTextFile({
    required String inputValue, 
    required String fileName, 
  }) async {

    final decodeContent = base64.decode(inputValue);

    final getDirApplication = await getApplicationDocumentsDirectory();
    final offlineDirPath = Directory('${getDirApplication.path}/offline_files');

    if (!offlineDirPath.existsSync()) {
      offlineDirPath.createSync();
    }

    final setupFiles = File('${offlineDirPath.path}/$fileName');
    await setupFiles.writeAsBytes(decodeContent);

  }

  Future<void> _videoGallerySaver(Uint8List videoData, String fileName) async {

    final directory = Platform.isAndroid 
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();

    final videoPath = '${directory!.path}/Flowstorage-$fileName';
    final videoFile = File(videoPath);
    
    await videoFile.writeAsBytes(videoData);

    await GallerySaver.saveVideo(videoPath);
    
    await videoFile.delete();

  }

  Future<void> downloadFile(String fileName) async {

    await init();    

    const Set<String> generalNonTextFileType = {
      "pdf","exe","apk",
      ...Globals.audioType,
      ...Globals.excelType,
      ...Globals.wordType,
      ...Globals.ptxType
    };

    final file = File('${offlineDirs.path}/$fileName');
    final fileDataValue = await file.readAsBytes();
    
    final fileType = fileName.split('.').last;

    if(Globals.imageType.contains(fileType)) {
      final setupName = "Flowstorage-$fileName";
      await ImageGallerySaver.saveImage(fileDataValue, name: setupName);

    } else if (Globals.videoType.contains(fileType)) {
      final decompressFileData = CompressorApi.decompressFile(fileDataValue);
      await _videoGallerySaver(decompressFileData, fileName);

    } else if (Globals.textType.contains(fileType)) {
      final decompressedFile = CompressorApi.decompressFile(fileDataValue);
      final textFileContent = utf8.decode(decompressedFile);

      await SaveApi().saveFile(
        fileName: fileName, fileData: textFileContent);

    } else if (generalNonTextFileType.contains(fileType)) {
      final decompressFileData = CompressorApi.decompressFile(fileDataValue);

      await SaveApi().saveFile(
        fileName: fileName, fileData: decompressFileData);

    }
      
  }

  Future<Uint8List> loadOfflineFileByte(String fileName) async {

    final offlineDirsPath = await OfflineModel().returnOfflinePath();
    
    final file = File('${offlineDirsPath.path}/$fileName');

    if (await file.exists()) {
      final fileContent = await file.readAsBytes();
      return CompressorApi.
            decompressFile(fileContent);

    } else {
      throw Exception('File not found');

    }
    
  }

  Future<void> processSaveOfflineFile({
    required String fileName, 
    required Uint8List fileData,
  }) async {

    try {
      
      await saveOfflineFile(
        fileName: fileName, fileData: fileData);
      
      SnackAlert.okSnack(
        message: "${ShortenText().cutText(fileName)} Now available offline.", icon: Icons.check);
      
    } catch (err) {
      SnackAlert.errorSnack("An error occurred.");
    }

  }

}
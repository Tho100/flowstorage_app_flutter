import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class SimplifyDownload {

  String? fileNameValue;
  String? currentTableValue;
  Uint8List? fileDataValue;
  
  SimplifyDownload({
    required String? fileName, 
    required String currentTable,
    required Uint8List? fileData
  }) {
    fileNameValue = fileName;
    fileDataValue = fileData;
    currentTableValue = currentTable;
  } 

  Future<void> _videoGallerySaver() async {

    final directory = Platform.isAndroid 
      ? await getExternalStorageDirectory()
      : await getApplicationDocumentsDirectory();

    final videoPath = '${directory!.path}/Flowstorage-$fileNameValue';
    final videoFile = File(videoPath);
    
    await videoFile.writeAsBytes(fileDataValue!);

    await GallerySaver.saveVideo(videoPath);
    
    await videoFile.delete();

  }

  Future<void> downloadFile() async {

    try {

      const generalFilesTableName = {GlobalsTable.homeText, GlobalsTable.psText, GlobalsTable.homeVideo, GlobalsTable.psVideo};

      if([GlobalsTable.homeImage, GlobalsTable.psImage].contains(currentTableValue)) {
        final setupName = "Flowstorage-$fileNameValue";
        await ImageGallerySaver.saveImage(fileDataValue!, name: setupName);

      } else if ([GlobalsTable.homeVideo, GlobalsTable.psVideo].contains(currentTableValue)) { 
        await _videoGallerySaver();

      } else if ([GlobalsTable.homeText, GlobalsTable.psText].contains(currentTableValue)) {
        final textFileContent = utf8.decode(fileDataValue!);
        await SaveApi().saveFile(
          fileName: fileNameValue!, fileData: textFileContent);

      } else if (!(generalFilesTableName.contains(currentTableValue))) {
        await SaveApi().saveFile(
          fileName: fileNameValue!, fileData: fileDataValue!);

      }

      await CallNotify().downloadedNotification(
        fileName: fileNameValue!
      );

    } catch (err, st) {
      Logger().e("Exception from downloadFile {SimplifyDownload}", err, st);
      await CallNotify().customNotification(title: "Something went wrong",subMessage: "Failed to download $fileNameValue");
    } 
   
  }

}
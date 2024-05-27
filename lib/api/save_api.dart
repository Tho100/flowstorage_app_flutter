import 'dart:io';
import 'dart:typed_data';
import 'package:logger/logger.dart';

class SaveApi {
  
  final logger = Logger();

  final downloadPath = "/storage/emulated/0/Download";

  Future<String> saveFile({
    required String fileName, 
    required dynamic fileData
  }) async {

    final filePath = "$downloadPath/Flowstorage-$fileName";
    final file = File(filePath);

    await file.create();

    try {

      if(fileData is Uint8List?) {
        await file.writeAsBytes(fileData!);

      } else if (fileData is String) {
        await file.writeAsString(fileData);

      }

      return filePath;

    } catch (err) {
      logger.e('Exception from saveFile {save_api}');
    }

    return "";
    
  }

  Future<void> createDirectoryFolder({
    required String folderName
  }) async {

    final folder = Directory('$downloadPath/$folderName');

    if (!(await folder.exists())) {
      await folder.create(recursive: true); 

    } else {
      return;

    }

  }

  Future<void> saveDirectoryFolderFiles({
    required String folderName,
    required String fileName,
    required dynamic fileData
  }) async {

    final filePath = "$downloadPath/$folderName/Flowstorage-$fileName";
    final file = File(filePath);

    await file.create();

    try {

      if(fileData is Uint8List) {
        await file.writeAsBytes(fileData);

      } else if (fileData is String) {
        await file.writeAsString(fileData);

      }

    } catch (err) {
      logger.e('Exception from saveFile {save_api}');
    }
    
  }

}
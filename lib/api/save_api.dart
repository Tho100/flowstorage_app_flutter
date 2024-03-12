import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';

class SaveApi {
  
  final logger = Logger();

  Future<String> saveFile({
    required String fileName, 
    required dynamic fileData,
  }) async {
    
    final result = await FilePicker.platform.getDirectoryPath();

    if (result != null && result.isNotEmpty) {

      final getFilePath = '$result/$fileName';
      final file = File(getFilePath);

      if (fileData is Uint8List) {
        await file.writeAsBytes(fileData);

      } else if (fileData is String) {
        await file.writeAsString(fileData);

      } else {
        logger.e('Exception from saveMultipleFiles {save_api}: unsupported file format');

      }

      return file.path;

    }

    return "";
    
  }

  Future<void> saveMultipleFiles({
    required String directoryPath,
    required String fileName,
    required dynamic fileData,
  }) async {

    final path = '$directoryPath/$fileName';
    final file = File(path);
   
    if (fileData is Uint8List) {
      await file.writeAsBytes(fileData);
      
    } else if (fileData is String) {
      await file.writeAsString(fileData);

    } else {
      logger.e('Exception from saveMultipleFiles {save_api}: unsupported file format');

    }

  }

}
import 'package:file_picker/file_picker.dart';
import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class SaveDirectory {

  final userData = GetIt.instance<UserDataProvider>();

  final encryption = EncryptionClass();
  
  Future<List<Map<String, dynamic>>> retrieveParams(String dirName) async {

    final conn = await SqlConnection.initializeConnection();

    final directoryName = encryption.encrypt(dirName);

    const query = 'SELECT CUST_FILE_PATH, CUST_FILE FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dirname';
    final params = {'username': userData.username, 'dirname': directoryName};

    try {

      final result = await conn.execute(query, params);
      final dataSet = <Map<String, dynamic>>[];

      Uint8List fileBytes = Uint8List(0);

      for (final row in result.rows) {

        final encryptedFileNames = row.assoc()['CUST_FILE_PATH']!;
        final fileNames = encryption.decrypt(encryptedFileNames);

        final fileTypes = fileNames.split('.').last;

        final encryptedFileByte = row.assoc()['CUST_FILE']!;

        if(Globals.imageType.contains(fileTypes)) {
          fileBytes = base64.decode(encryption.decrypt(encryptedFileByte));

        } else {
          final compressedFileData = base64.decode(encryption.decrypt(encryptedFileByte));
          final decompressFileData = CompressorApi.decompressFile(compressedFileData);
          fileBytes = decompressFileData;

        }

        final buffer = ByteData.view(fileBytes.buffer);
        final bufferedFileBytes = Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);

        final data = {
          'name': fileNames,
          'file_data': bufferedFileBytes,
        };
        dataSet.add(data);
      }

      return dataSet;

    } catch (err, st) {
      Logger().e("Exception from retrieveParams {directory_data}", err, st);
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> selectDirectoryUserDirectory({
    required String directoryName,
    required BuildContext context
  }) async {

    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      await downloadDirectoryFiles(
        directoryName: directoryName, directoryPath: directoryPath, context: context);

    } else {
      return;

    }
    
  }

  Future<void> downloadDirectoryFiles({
    required String directoryName,
    required String directoryPath,
    required BuildContext context
  }) async {

    try {

      final loadingDialog = SingleTextLoading(); 
           
      loadingDialog.startLoading(title: "Saving...", context: context);

      final dataList = await retrieveParams(directoryName);

      final nameList = dataList.map((data) => data['name'] as String).toList();
      final byteList = dataList.map((data) => data['file_data'] as Uint8List).toList();
      
      for(int i=0; i<nameList.length; i++) {
        await SaveApi().saveMultipleFiles(directoryPath: directoryPath, fileName: nameList[i], fileData: byteList[i]);
      }

      loadingDialog.stopLoading();
      
      SnakeAlert.okSnake(message: "${nameList.length} item(s) has been saved.",icon: Icons.check);

      await CallNotify().customNotification(title: "Directory Saved", subMesssage: "${nameList.length} File(s) has been downloaded");

    } catch (err) {
      SnakeAlert.errorSnake("Failed to save the directory.");
    }

  }
}
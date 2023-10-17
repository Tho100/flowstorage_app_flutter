import 'dart:convert';
import 'dart:io';

import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:get_it/get_it.dart';

class UpdateValues  {
  
  Future<void> insertValueParams({
    required String tableName,
    required String filePath,
    required String userName,
    required dynamic newValue,
    required String columnName,
  }) async {
  
    final conn = await SqlConnection.initializeConnection();

    final encryption = EncryptionClass();
    final tempData = GetIt.instance<TempDataProvider>();

    final encryptedFilePath = encryption.encrypt(filePath);
    final encryptedFileVal = encryption.encrypt(newValue);

    if (tempData.origin == OriginFile.home) {

      if (tableName == "information") {

        final query = "UPDATE $tableName SET $columnName = :newuser WHERE CUST_USERNAME = :username";
        final params = {"newuser": newValue, "username": userName};

        await conn.execute(query, params);

      } else if (tableName == GlobalsTable.homeText) {

        final List<int> getUnits = newValue.codeUnits;  

        final base64StringTextData = base64.encode(getUnits);
        final compressedTextData = CompressorApi.compressByte(base64.decode(base64StringTextData));

        final compressedBase64TextData = base64.encode(compressedTextData);
        final encryptedFileText = encryption.encrypt(compressedBase64TextData);

        final query = "UPDATE $tableName SET CUST_FILE = :newvalue WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
        final params = {"username": userName, "newvalue": encryptedFileText, "filename": encryptedFilePath};

        await conn.execute(query, params);

      } else if (tableName == GlobalsTable.homeText && tempData.origin == OriginFile.offline) {

        /*final List<int> getUnits = newValue.codeUnits;  

        final base64StringTextData = base64.encode(getUnits);
        final compressedTextData = CompressorApi.compressByte(base64.decode(base64StringTextData));

        final compressedBase64TextData = base64.encode(compressedTextData);

        final offlineDir = await OfflineMode().returnOfflinePath();
        final textFile = File("$offlineDir/$filePath");

        String content = textFile.readAsStringSync();*/
        //print(content);

        // update text file

      }
      
    } else if (tempData.origin == OriginFile.directory) {

      final encryptedDirectoryName = EncryptionClass().encrypt(tempData.directoryName);

      const query = "UPDATE upload_info_directory SET CUST_FILE = :newvalue WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND DIR_NAME = :dirname";
      final params = {"username": userName, "newvalue": encryptedFileVal, "filename": encryptedFilePath, "dirname": encryptedDirectoryName};

      await conn.execute(query, params);

    } else if (tempData.origin == OriginFile.folder) {

      final encryptedFolderName = EncryptionClass().encrypt(tempData.folderName);

      const query = "UPDATE folder_upload_info SET CUST_FILE = :newvalue WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND FOLDER_TITLE = :foldname";
      final params = {"username": userName, "newvalue": encryptedFileVal, "filename": encryptedFilePath, "foldname": encryptedFolderName};

      await conn.execute(query, params);

    } 

  }
}
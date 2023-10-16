import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
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

    final encryptedFilePath = encryption.encrypt(filePath);;
    final encryptedFileVal = encryption.encrypt(newValue);

    if (tempData.origin == OriginFile.home) {

      if (tableName == "information") {

        final query = "UPDATE $tableName SET $columnName = :newuser WHERE CUST_USERNAME = :username";
        final params = {"newuser": newValue, "username": userName};

        await conn.execute(query, params);

      } else if (tableName == GlobalsTable.homeText) {

        final List<int> getUnits = newValue.codeUnits;  
        final String getEncodedVers = base64.encode(getUnits);
        final encryptedFileValText = EncryptionClass().encrypt(getEncodedVers);

        final query = "UPDATE $tableName SET CUST_FILE = :newvalue WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
        final params = {"username": userName, "newvalue": encryptedFileValText, "filename": encryptedFilePath};

        await conn.execute(query, params);

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
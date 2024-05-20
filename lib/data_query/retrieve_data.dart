import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/special_file.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mysql_client/mysql_client.dart';

class RetrieveData {

  final encryption = EncryptionClass();
  final specialFile = SpecialFile();

  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  Future<Uint8List> _getDataBytes({
    required MySQLConnectionPool conn,
    required String username,
    required String fileName,
    required String tableName,
  }) async {

    final fileType = fileName.split('.').last;
    final encryptedFileName = encryption.encrypt(fileName);

    late final String query;
    late final Map<String, String> params;

    switch (tempData.origin) {
      case OriginFile.home:
        query = "SELECT CUST_FILE FROM $tableName WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
        params = {"username": username, "filename": encryptedFileName};
        break;

      case OriginFile.folder:
        query = "SELECT CUST_FILE FROM folder_upload_info WHERE CUST_USERNAME = :username AND FOLDER_NAME = :foldtitle AND CUST_FILE_PATH = :filename";
        params = {"username": username, "foldtitle": encryption.encrypt(tempData.folderName), "filename": encryptedFileName};
        break;

      case OriginFile.directory:
        query = "SELECT CUST_FILE FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dirname AND CUST_FILE_PATH = :filename";
        params = {"username": username, "dirname": encryption.encrypt(tempData.directoryName), "filename": encryptedFileName};
        break;

      case OriginFile.sharedMe:
        query = "SELECT CUST_FILE FROM CUST_SHARING WHERE CUST_TO = :username AND CUST_FILE_PATH = :filename";
        params = {"username": username, "filename": encryptedFileName};
        break;

      case OriginFile.sharedOther:
        query = "SELECT CUST_FILE FROM CUST_SHARING WHERE CUST_FROM = :username AND CUST_FILE_PATH = :filename";
        params = {"username": username, "filename": encryptedFileName};
        break;

      case OriginFile.public:
      case OriginFile.publicSearching:
        final toPsFileName = _returnPsTable(tableName);

        final indexUploaderName = storageData.fileNamesFilteredList.indexOf(fileName);
        final uploaderName = psStorageData.psUploaderList[indexUploaderName];

        query = "SELECT CUST_FILE FROM $toPsFileName WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
        params = {"username": uploaderName, "filename": encryptedFileName};
        break;

      case OriginFile.offline:
        break;

    }

    final row = (await conn.execute(query, params)).rows.first;
    
    final decryptedData = specialFile.ignoreEncryption(fileType)
      ? row.assoc()['CUST_FILE']! 
      : encryption.decrypt(row.assoc()['CUST_FILE']!);

    final fileByteData = base64.decode(decryptedData);
    final decompressedData = CompressorApi.decompressFile(fileByteData);

    return decompressedData.buffer.asUint8List(decompressedData.offsetInBytes, decompressedData.lengthInBytes);
    
  }

  String _returnPsTable(String tableName) {
    return GlobalsTable.tableNames.contains(tableName)
      ? GlobalsTable.publicToPsTables[tableName]!
      : tableName;
  }

  Future<Uint8List> getFileData(
    String username,
    String fileName,
    String tableName
  ) async {

    final conn = await SqlConnection.initializeConnection();

    return await _getDataBytes(
      conn: conn,
      username: username,
      fileName: fileName,
      tableName: tableName
    );

  }

}
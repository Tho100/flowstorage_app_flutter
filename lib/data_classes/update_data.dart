import 'dart:convert';

import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mysql_client/mysql_client.dart';

class UpdateValues  {

  final String newValue;
  final String fileName;
  final String tableName;
  final String columnName;
  final String userName;

  UpdateValues({
    required this.newValue,
    required this.fileName,
    required this.tableName,
    required this.columnName,
    required this.userName
  });

  late String? encryptedFileName;
  late String? encryptedFileValue;
  
  final encryption = EncryptionClass();
  final tempData = GetIt.instance<TempDataProvider>();

  late final MySQLConnectionPool conn;

  String returnEncryptedTextData() {
    final List<int> getUnits = newValue.codeUnits;  
    final base64StringTextData = base64.encode(getUnits);
    final compressedTextData = CompressorApi.compressByte(base64.decode(base64StringTextData));

    final compressedBase64TextData = base64.encode(compressedTextData);
    final encryptedFileText = encryption.encrypt(compressedBase64TextData);

    return encryptedFileText;
  }

  void _updateOfflineTextFile() {
    final toUtf8Bytes = utf8.encode(newValue);
    final base64Encoded = base64.encode(toUtf8Bytes);
    final base64Bytes = base64.decode(base64Encoded);

    final compressedFileBytes = CompressorApi.compressByte(base64Bytes);
    final compressedFileBase64 = base64.encode(compressedFileBytes);

    OfflineMode().saveOfflineTextFile(
      inputValue: compressedFileBase64, 
      fileName: tempData.selectedFileName, 
    );
  }

  Future<void> _updateTextFile() async {
    final encryptedFileText = returnEncryptedTextData();

    final query = "UPDATE $tableName SET CUST_FILE = :newvalue WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
    final params = {"username": userName, "newvalue": encryptedFileText, "filename": encryptedFileName};

    await conn.execute(query, params);
  }

  Future<void> _updateDirectoryData() async {
    final encryptedFileText = returnEncryptedTextData();
    final encryptedDirectoryName = encryption.encrypt(tempData.directoryName);

    const query = "UPDATE upload_info_directory SET CUST_FILE = :newvalue WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND DIR_NAME = :dirname";
    final params = {"username": userName, "newvalue": encryptedFileText, "filename": encryptedFileName, "dirname": encryptedDirectoryName};

    await conn.execute(query, params);
  }

  Future<void> _updateFolderData() async {
    final encryptedFileText = returnEncryptedTextData();
    final encryptedFolderName = encryption.encrypt(tempData.folderName);

    const query = "UPDATE folder_upload_info SET CUST_FILE = :newvalue WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename AND FOLDER_TITLE = :foldname";
    final params = {"username": userName, "newvalue": encryptedFileText, "filename": encryptedFileName, "foldname": encryptedFolderName};

    await conn.execute(query, params);
  }

  Future<void> updateDataValues() async {
  
    conn = await SqlConnection.initializeConnection();

    encryptedFileName = encryption.encrypt(fileName);
    encryptedFileValue = encryption.encrypt(newValue);

    final fileType = fileName.split('.').last;

    if (tempData.origin == OriginFile.home) {

      if (tableName == GlobalsTable.homeText) {
        await _updateTextFile();

      } 
      
    } else if (tempData.origin == OriginFile.directory) {
      await _updateDirectoryData();

    } else if (tempData.origin == OriginFile.folder) {
      await _updateFolderData();

    } else if (tempData.origin == OriginFile.offline && Globals.textType.contains(fileType)) {
      _updateOfflineTextFile();

    }

  }
}
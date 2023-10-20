import 'dart:convert';

import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/sharing_username.dart';
import 'package:get_it/get_it.dart';
import 'package:mysql_client/mysql_client.dart';

class UpdateTextData  {

  final String newValue;
  final String fileName;
  final String tableName;
  final String userName;
  final int tappedIndex;

  UpdateTextData({
    required this.newValue,
    required this.fileName,
    required this.tableName,
    required this.userName,
    required this.tappedIndex
  });

  late String? encryptedFileName;
  late String? encryptedFileValue;
  late String? fileType;

  final encryption = EncryptionClass();
  final sharingName = SharingName();

  final tempData = GetIt.instance<TempDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  late final MySQLConnectionPool conn;

  String returnEncryptedTextData() {
    final List<int> getUnits = newValue.codeUnits;  
    final base64StringTextData = base64.encode(getUnits);
    final compressedTextData = CompressorApi.compressByte(base64.decode(base64StringTextData));

    final compressedBase64TextData = base64.encode(compressedTextData);
    final encryptedFileText = encryption.encrypt(compressedBase64TextData);

    return encryptedFileText;
  }

  void _updateOfflineData() {
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

  Future<void> _updateSharedOthersData() async {
    final encryptedFileText = returnEncryptedTextData();
    final receiverUsername = await sharingName.shareToOtherName(usernameIndex: tappedIndex); 

    const query = "UPDATE cust_sharing SET CUST_FILE = :newvalue WHERE CUST_TO = :receiver_username AND CUST_FROM = :username AND CUST_FILE_PATH = :filename";
    final params = {
      "newvalue": encryptedFileText, 
      "receiver_username": receiverUsername, 
      "username": userData.username, 
      "filename": encryptedFileName
    };

    await conn.execute(query, params);
  }

  Future<void> _updateSharedMeData() async {
    final encryptedFileText = returnEncryptedTextData();
    final sharerUsername = await sharingName.sharerName();

    const query = "UPDATE cust_sharing SET CUST_FILE = :newvalue WHERE CUST_TO = :username AND CUST_FROM = :sender_username AND CUST_FILE_PATH = :filename";
    final params = {
      "newvalue": encryptedFileText, 
      "username": userData.username, 
      "sender_username": sharerUsername, 
      "filename": encryptedFileName
    };

    await conn.execute(query, params);
  }

  Future<void> _updatePublicData() async {
    final encryptedFileText = returnEncryptedTextData();
    
    const query = "UPDATE ps_info_text SET CUST_FILE = :newvalue WHERE CUST_USERNAME = :username AND CUST_FILE_PATH = :filename";
    final params = {
      "newvalue": encryptedFileText, 
      "username": userData.username, 
      "filename": encryptedFileName
    };

    await conn.execute(query, params);
  }

  Future<void> update() async {
  
    conn = await SqlConnection.initializeConnection();

    encryptedFileName = encryption.encrypt(fileName);
    encryptedFileValue = encryption.encrypt(newValue);

    fileType = fileName.split('.').last;

    switch(tempData.origin) {
      case OriginFile.home: 
        await _updateTextFile();
        break;
      
      case OriginFile.directory:
        await _updateDirectoryData();
        break;

      case OriginFile.folder:
        await _updateFolderData();
        break;

      case OriginFile.offline:
        _updateOfflineData();
        break;

      case OriginFile.sharedOther:
        await _updateSharedOthersData();
        break;
    
      case OriginFile.sharedMe:
        await _updateSharedMeData();
        break;
    
      case OriginFile.public:
        await _updatePublicData();
        break;
    }

    /*if (tempData.origin == OriginFile.home) {

      if (tableName == GlobalsTable.homeText) {
        await _updateTextFile();
      } 
      
    } else if (tempData.origin == OriginFile.directory) {
      await _updateDirectoryData();

    } else if (tempData.origin == OriginFile.folder) {
      await _updateFolderData();

    } else if (tempData.origin == OriginFile.offline && Globals.textType.contains(fileType)) {
      _updateOfflineData();

    } else if (tempData.origin == OriginFile.sharedOther) {
      await _updateSharedOthersData();

    } else if (tempData.origin == OriginFile.sharedMe) {
      await _updateSharedMeData();
    }*/

  }
}
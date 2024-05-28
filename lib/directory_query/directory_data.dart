import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/format_date.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mysql_client/mysql_client.dart';

class DirectoryDataReceiver {

  final userData = GetIt.instance<UserDataProvider>();

  final encryption = EncryptionClass();
  final getAssets = GetAssets();
  
  Future<String> retrieveFiles({
    required MySQLConnectionPool conn, 
    required String directoryTitle,
    required String query,
    required String fileName,
    required String returnColumn,
  }) async {

    final params = {
      "username": userData.username, 
      "dirname": directoryTitle,
      "filename": fileName
    };

    final results = await conn.execute(query, params);

    return results.rows.last.assoc()[returnColumn]!;

  }
  
  Future<List<Map<String, dynamic>>> retrieveParams({
    required String dirName
  }) async {

    final encryptedDirectoryName = encryption.encrypt(dirName);

    const querySelectMetadata = 'SELECT CUST_FILE_PATH, UPLOAD_DATE FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dirname';
    final params = {
      'username': userData.username, 
      'dirname': encryptedDirectoryName
    };

    const querySelectThumbnail = 'SELECT CUST_THUMB FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dirname AND CUST_FILE_PATH = :filename';
    const querySelectImage = 'SELECT CUST_FILE FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dirname AND CUST_FILE_PATH = :filename';

    try {

      final conn = await SqlConnection.initializeConnection();

      final results = await conn.execute(querySelectMetadata, params);
      final dataSet = <Map<String, dynamic>>[];

      Uint8List fileBytes = Uint8List(0);

      for (final row in results.rows) {

        final encryptedFileNames = row.assoc()['CUST_FILE_PATH']!;
        final decryptedFileNames = encryption.decrypt(encryptedFileNames);

        final fileType = decryptedFileNames.split('.').last;

        if(Globals.imageType.contains(fileType)) {

          final encryptedImageBase64 = await retrieveFiles(
            conn: conn, 
            directoryTitle: encryptedDirectoryName, 
            query: querySelectImage,
            fileName: encryptedFileNames, 
            returnColumn: "CUST_FILE"
          );

          fileBytes = base64.decode(encryption.decrypt(encryptedImageBase64));
      
        } else if (Globals.videoType.contains(fileType)) {

          final thumbnailBase64 = await retrieveFiles(
            conn: conn, 
            directoryTitle: encryptedDirectoryName, 
            query: querySelectThumbnail, 
            fileName: encryptedFileNames,
            returnColumn: "CUST_THUMB"
          );

          fileBytes = base64.decode(thumbnailBase64);

        } else {
          fileBytes = await getAssets.loadAssetsData(Globals.fileTypeToAssets[fileType]!);

        }

        final dateValue = row.assoc()['UPLOAD_DATE']!;
        final formattedDate = FormatDate().formatDifference(dateValue);

        final buffer = ByteData.view(fileBytes.buffer);
        final bufferedFileBytes = Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);

        final data = {
          'name': decryptedFileNames,
          'date': formattedDate,
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

}
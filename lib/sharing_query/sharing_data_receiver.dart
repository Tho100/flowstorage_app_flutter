import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/format_date.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flutter/services.dart';
import 'package:mysql_client/mysql_client.dart';

class SharingDataReceiver {

  final encryption = EncryptionClass();
  final getAssets = GetAssets();
  
  Future<String> retrieveFiles({
    required String query,
    required String returnedColumn,
    required String fileName,
    required String username,
    required MySQLConnectionPool conn
  }) async {
    
    final params = {'username': username, 'filename': fileName};
    final results = await conn.execute(query, params);

    return results.rows.last.assoc()[returnedColumn]!;

  }

  Future<List<Map<String, dynamic>>> retrieveParams(String username, String originFrom) async {

    final selectUsernameColumn = originFrom == 'sharedFiles' ? 'CUST_TO' : 'CUST_FROM';
    final selectSharedColumn = originFrom == 'sharedFiles' ? 'CUST_FROM' : 'CUST_TO';

    final query = 
      'SELECT CUST_FILE_PATH, $selectUsernameColumn, UPLOAD_DATE FROM cust_sharing WHERE $selectSharedColumn = :username';
    final params = {'username': username};

    try {

      final conn = await SqlConnection.initializeConnection();

      final result = await conn.execute(query, params);
      final dataSet = <Map<String, dynamic>>[];

      Uint8List fileBytes = Uint8List(0);

      for (final row in result.rows) {

        final sharedUsername = row.assoc()[selectUsernameColumn];

        final encryptedFileNames = row.assoc()['CUST_FILE_PATH']!;
        final decryptedFileNames = encryption.decrypt(encryptedFileNames);

        final fileType = decryptedFileNames.split('.').last;

        if(Globals.imageType.contains(fileType)) {

          final querySelectImage =
                'SELECT CUST_FILE FROM cust_sharing WHERE ${originFrom == 'sharedFiles' ? 'CUST_FROM' : 'CUST_TO'} = :username AND CUST_FILE_PATH = :filename';

          final encryptedBase64 = await retrieveFiles(
            query: querySelectImage, 
            returnedColumn: "CUST_FILE", 
            fileName: encryptedFileNames, 
            username: username, 
            conn: conn
          );

          fileBytes = base64.decode(encryption.decrypt(encryptedBase64));

        } else if (Globals.videoType.contains(fileType)) {

          final querySelectThumbnail =
                'SELECT CUST_THUMB FROM cust_sharing WHERE ${originFrom == 'sharedFiles' ? 'CUST_FROM' : 'CUST_TO'} = :username AND CUST_FILE_PATH = :filename';

          final base64EncodedThumbnail = await retrieveFiles(
            query: querySelectThumbnail, 
            returnedColumn: "CUST_THUMB", 
            fileName: encryptedFileNames, 
            username: username, 
            conn: conn
          );

          fileBytes = base64.decode(base64EncodedThumbnail);

        } else {
          fileBytes = await getAssets.loadAssetsData(Globals.fileTypeToAssets[fileType]!);

        }

        final dateValue = row.assoc()['UPLOAD_DATE']!;
        final formattedDate = FormatDate().format(dateValue);

        final buffer = ByteData.view(fileBytes.buffer);

        final bufferedFileBytes = Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);

        final data = {
          'name': decryptedFileNames,
          'date': '$sharedUsername ${GlobalsStyle.dotSeparator} $formattedDate',
          'file_data': bufferedFileBytes,
        };
        
        dataSet.add(data);

      }

      return dataSet;

    } catch (err) {
      return <Map<String, dynamic>>[];
    }

  }
  
}

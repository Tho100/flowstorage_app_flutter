import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';

class SharingDataReceiver {

  final encryption = EncryptionClass();
  final getAssets = GetAssets();
  final now = DateTime.now();
  
  Future<String> retrieveFiles({
    required String query,
    required String returnedColumn,
    required String fileName,
    required String username,
    required MySQLConnectionPool connection
  }) async {
    
    final params = {'username': username, 'filename': fileName};
    final executeRetrieval = await connection.execute(query, params);

    for (final row in executeRetrieval.rows) {
      return row.assoc()[returnedColumn]!;
    }

    return '';
  }

  Future<List<Map<String, dynamic>>> retrieveParams(String username, String originFrom) async {

    final query =
        'SELECT CUST_FILE_PATH, UPLOAD_DATE FROM cust_sharing WHERE ${originFrom == 'sharedFiles' ? 'CUST_FROM' : 'CUST_TO'} = :username';
    final params = {'username': username};

    try {

      final conn = await SqlConnection.initializeConnection();

      final result = await conn.execute(query, params);
      final dataSet = <Map<String, dynamic>>[];

      Uint8List fileBytes = Uint8List(0);

      String encryptedFileNames;
      String decryptedFileNames;
      String fileType;

      for (final row in result.rows) {

        encryptedFileNames = row.assoc()['CUST_FILE_PATH']!;
        decryptedFileNames = encryption.decrypt(encryptedFileNames);
        fileType = decryptedFileNames.split('.').last.toLowerCase();

        if(Globals.imageType.contains(fileType)) {

          final retrieveEncryptedMetadata =
                'SELECT CUST_FILE FROM cust_sharing WHERE ${originFrom == 'sharedFiles' ? 'CUST_FROM' : 'CUST_TO'} = :username AND CUST_FILE_PATH = :filename';

          final encryptedBase64 = await retrieveFiles(
            query: retrieveEncryptedMetadata, 
            returnedColumn: "CUST_FILE", 
            fileName: encryptedFileNames, 
            username: username, 
            connection: conn
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
            connection: conn
          );

          fileBytes = base64.decode(base64EncodedThumbnail);

        } else {
          fileBytes = await getAssets.loadAssetsData(Globals.fileTypeToAssets[fileType]!);

        }

        final dateValue = row.assoc()['UPLOAD_DATE']!;
        final dateValueWithDashes = dateValue.replaceAll('/', '-');
        final dateComponents = dateValueWithDashes.split('-');
        
        final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));
        final difference = now.difference(date).inDays;

        final formattedDate = DateFormat('MMM d yyyy').format(date);
        final buffer = ByteData.view(fileBytes.buffer);

        final bufferedFileBytes = Uint8List.view(buffer.buffer, buffer.offsetInBytes, buffer.lengthInBytes);

        final data = {
          'name': decryptedFileNames,
          'date': '$difference days ago ${GlobalsStyle.dotSeperator} $formattedDate',
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

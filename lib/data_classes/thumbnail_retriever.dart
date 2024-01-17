import 'dart:convert';
import 'dart:typed_data';
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mysql_client/mysql_client.dart';

class ThumbnailGetter {
  
  final userData = GetIt.instance<UserDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();
  final encryption = EncryptionClass();

  Future<List<Uint8List>> retrieveParams(MySQLConnectionPool conn) async {
    
    final conn = await SqlConnection.initializeConnection();

    String query;
    Map<String, dynamic> params;
  
    query = "SELECT CUST_THUMB FROM ";

    if (tempData.origin == OriginFile.home) {
      query += "${GlobalsTable.homeVideo} WHERE CUST_USERNAME = :username";

    } else {
      query += "cust_sharing WHERE CUST_FROM = :username";

      if (tempData.origin == OriginFile.sharedOther) {
        query += " AND CUST_TO = :username";

      } else if (tempData.origin == OriginFile.sharedMe) {
        query += " AND CUST_FILE_PATH = :filename";
        params = {'username': userData.username};

      }
    }

    params = {'username': userData.username};

    final getThumbBytesQue = await conn.execute(query, params);
    final thumbnailBytesList = <Uint8List>[];

    for (final res in getThumbBytesQue.rows) {
      final thumbBytes = res.assoc()['CUST_THUMB'];
      thumbnailBytesList.add(base64.decode(thumbBytes!));
    }

    return thumbnailBytesList;
  
  }

  Future<String?> retrieveParamsSingle({
    required String? fileName,
  }) async {
    
    final conn = await SqlConnection.initializeConnection();

    final encryptedFileName = encryption.encrypt(fileName);

    if (tempData.origin == OriginFile.sharedOther) {

      const query = "SELECT CUST_THUMB FROM cust_sharing WHERE CUST_FROM = :username AND CUST_FILE_PATH = :filename";
      final params = {
        'username': userData.username,
        'filename': encryptedFileName,
      };

      final results = await conn.execute(query,params);

      return results.rows.last.assoc()['CUST_THUMB'];

    } else if (tempData.origin == OriginFile.sharedMe) {

      const query = "SELECT CUST_THUMB FROM cust_sharing WHERE CUST_TO = :username AND CUST_FILE_PATH = :filename";
      final params = {
        'username': userData.username,
        'filename': encryptedFileName,
      };

      final results = await conn.execute(query,params);

      return results.rows.last.assoc()['CUST_THUMB'];

    }
  
    return '';

  }
  
}
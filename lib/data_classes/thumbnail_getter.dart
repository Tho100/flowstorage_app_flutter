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

  Future<List<Uint8List>> getThumbnails(MySQLConnectionPool conn) async {
    
    String query;
  
    query = "SELECT CUST_THUMB FROM ";

    if (tempData.origin == OriginFile.home) {
      query += "${GlobalsTable.homeVideo} WHERE CUST_USERNAME = :username";

    } else {
      query += "cust_sharing WHERE CUST_FROM = :username";

      if (tempData.origin == OriginFile.sharedOther) {
        query += " AND CUST_TO = :username";

      } else if (tempData.origin == OriginFile.sharedMe) {
        query += " AND CUST_FILE_PATH = :filename";

      }
      
    }

    final param = {'username': userData.username};

    final results = await conn.execute(query, param);

    return results.rows.map((row) => 
      base64.decode(row.assoc()['CUST_THUMB']!)
    ).toList();
  
  }

  Future<String?> getSingleThumbnail({
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
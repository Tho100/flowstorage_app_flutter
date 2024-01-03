import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mysql_client/mysql_client.dart';

class ThumbnailGetterPs {

  final userData = GetIt.instance<UserDataProvider>();

  Future<List<Uint8List>> retrieveParams(MySQLConnectionPool conn) async {

    const query = 'SELECT CUST_THUMB FROM ps_info_video ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';
    
    final retrievedThumbnails = await conn.execute(query);

    return retrievedThumbnails.rows
      .map((row) => base64.decode(row.assoc()['CUST_THUMB']!))
      .toList();

  }

  Future<List<Uint8List>> myRetrieveParams(MySQLConnectionPool conn) async {

    final conn = await SqlConnection.initializeConnection();

    const query = 'SELECT CUST_THUMB FROM ps_info_video WHERE CUST_USERNAME = :username ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';
    
    final params = {'username': userData.username};
    final retrievedThumbnails = await conn.execute(query, params);

    return retrievedThumbnails.rows
      .map((row) => base64.decode(row.assoc()['CUST_THUMB']!))
      .toList();

  }

}
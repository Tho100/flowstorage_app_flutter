import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mysql_client/mysql_client.dart';

class NameGetterPs {

  final encryption = EncryptionClass();
  final userData = GetIt.instance<UserDataProvider>();

  Future<List<String>> myRetrieveParams(MySQLConnectionPool conn, String tableName) async {

    try {   

      final query = 'SELECT CUST_FILE_PATH FROM $tableName WHERE CUST_USERNAME = :username ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';

      final params = {'username': userData.username};
      final retrievedFilesName = await conn.execute(query, params);

      return retrievedFilesName.rows
        .map((row) => encryption.decrypt(row.assoc()['CUST_FILE_PATH']!))
        .toList();

    } catch (err) {
      return <String>[];
    } 

  }

  Future<List<String>> retrieveParams(MySQLConnectionPool conn, String tableName) async {

    try {   

      final query = 'SELECT CUST_FILE_PATH FROM $tableName ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';

      final retrievedFilesName = await conn.execute(query);

      return retrievedFilesName.rows
        .map((row) => encryption.decrypt(row.assoc()['CUST_FILE_PATH']!))
        .toList();

    } catch (err) {
      return <String>[];
    } 

  }

}
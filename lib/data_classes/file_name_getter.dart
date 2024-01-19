import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:mysql_client/mysql_client.dart';

class FileNameGetter {

  final encryption = EncryptionClass();

  Future<List<String>> retrieveParams(MySQLConnectionPool conn, String username, String tableName) async {

    try {
      
      final query = tableName != GlobalsTable.directoryInfoTable
        ? 'SELECT CUST_FILE_PATH FROM $tableName WHERE CUST_USERNAME = :username'
        : 'SELECT DIR_NAME FROM file_info_directory WHERE CUST_USERNAME = :username';

      final params = {'username': username};

      final retrievedNames = await conn.execute(query, params);

      return retrievedNames.rows
        .map((row) => row.assoc()['CUST_FILE_PATH'] ?? row.assoc()['DIR_NAME'])
        .where((nameValues) => nameValues != null)
        .map((nameValues) => encryption.decrypt(nameValues))
        .toList();

    } catch (err) {
      return <String>[];
    } 

  }
}

import 'package:mysql_client/mysql_client.dart';

class UploaderGetterPs {

  Future<List<String>> retrieveParams(MySQLConnectionPool conn, String tableName) async {

    try {   

      final query = 'SELECT CUST_USERNAME FROM $tableName ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';

      final retrieveNames = await conn.execute(query);

      return retrieveNames.rows
        .map((row) => row.assoc()['CUST_USERNAME']!)
        .toList();

    } catch (err) {
      return <String>[];
    } 
    
  }
}
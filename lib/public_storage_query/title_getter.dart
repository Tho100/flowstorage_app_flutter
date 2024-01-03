import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mysql_client/mysql_client.dart';

class TitleGetterPs {

  final userData = GetIt.instance<UserDataProvider>();
  
  Future<List<String>> myGetTitleParams(MySQLConnectionPool conn, String tableName) async {

    try {

      final selectTitles = 'SELECT CUST_TITLE FROM $tableName WHERE CUST_USERNAME = :username ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';

      final params = {'username': userData.username};
      final retrievedTitles = await conn.execute(selectTitles, params);

      return retrievedTitles.rows
        .map((row) => row.assoc()['CUST_TITLE']!)
        .toList();

    } catch (err) {
      return <String>[];
    }

  }

  Future<List<String>> getTitleParams(MySQLConnectionPool conn, String tableName) async {

    try {

      final selectTitles = 'SELECT CUST_TITLE FROM $tableName ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';
      final retrievedTitles = await conn.execute(selectTitles);
      
      return retrievedTitles.rows
        .map((row) => row.assoc()['CUST_TITLE']!)
        .toList();

    } catch (err) {
      return <String>[];
    }

  }

}
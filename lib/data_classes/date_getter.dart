import 'package:flowstorage_fsc/helper/format_date.dart';
import 'package:mysql_client/mysql_client.dart';

class DateGetter {

  Future<List<String>> retrieveParams(MySQLConnectionPool conn, String username, String tableName) async {
    
    final selectUploadDate =
        "SELECT UPLOAD_DATE FROM $tableName WHERE CUST_USERNAME = :username";
    final params = {'username': username};
    
    final retrievedDate = await conn.execute(selectUploadDate, params);

    return retrievedDate.rows.map((res) {
      final dateValue = res.assoc()['UPLOAD_DATE']!;
      return FormatDate().formatDifference(dateValue);

    }).toList();

  }
}
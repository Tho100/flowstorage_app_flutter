import 'package:flowstorage_fsc/helper/format_date.dart';
import 'package:mysql_client/mysql_client.dart';

class FileDateGetter {

  final formatDate = FormatDate();

  Future<List<String>> getUploadDate(MySQLConnectionPool conn, String username, String tableName) async {
    
    try {

      final selectUploadDate =
          "SELECT UPLOAD_DATE FROM $tableName WHERE CUST_USERNAME = :username";
      final params = {'username': username};
      
      final retrievedDate = await conn.execute(selectUploadDate, params);

      return retrievedDate.rows.map((row) {
        final dateValue = row.assoc()['UPLOAD_DATE']!;
        return formatDate.formatDifference(dateValue);
      }).toList();

    } catch (err) {
      return <String>[];
    }

  }
  
}
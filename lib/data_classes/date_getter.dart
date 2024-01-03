import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:intl/intl.dart';
import 'package:mysql_client/mysql_client.dart';

class DateGetter {

  Future<List<String>> retrieveParams(MySQLConnectionPool conn, String username, String tableName) async {
    
    final selectUploadDate =
        "SELECT UPLOAD_DATE FROM $tableName WHERE CUST_USERNAME = :username";
    final params = {'username': username};
    
    final retrievedDate = await conn.execute(selectUploadDate, params);

    return retrievedDate.rows.map((res) {
      final dateValue = res.assoc()['UPLOAD_DATE']!;
      final dateValueWithDashes = dateValue.replaceAll('/', '-');
      final dateComponents = dateValueWithDashes.split('-');

      final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      final formattedDate = DateFormat('MMM d yyyy').format(date);
      return '$difference days ago ${GlobalsStyle.dotSeperator} $formattedDate';
      
    }).toList();

  }
}
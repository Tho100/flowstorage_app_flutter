import 'package:flowstorage_fsc/helper/format_date.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mysql_client/mysql_client.dart';

class DateGetterPs {

  final userData = GetIt.instance<UserDataProvider>();

  Future<List<String>> getMyUploadDate(MySQLConnectionPool conn, String tableName) async {

    final selectUploadDate = 'SELECT UPLOAD_DATE, CUST_TAG FROM $tableName WHERE CUST_USERNAME = :username ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';

    final params = {'username': userData.username};
    final results = await conn.execute(selectUploadDate,params);

    return results.rows.map((row) {
      final dateValue = row.assoc()['UPLOAD_DATE']!;
      final tagValue = row.assoc()['CUST_TAG']!;

      final formattedDate = FormatDate().formatDifference(dateValue);

      return '$formattedDate ${GlobalsStyle.dotSeparator} $tagValue';

    }).toList();

  }

  Future<List<String>> getUploadDate(MySQLConnectionPool conn, String tableName) async {
    
    final selectUploadDate = 'SELECT UPLOAD_DATE, CUST_TAG FROM $tableName ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';
    final results = await conn.execute(selectUploadDate);

    return results.rows.map((row) {
      final dateValue = row.assoc()['UPLOAD_DATE']!;
      final tagValue = row.assoc()['CUST_TAG']!;

      final formattedDate = FormatDate().formatDifference(dateValue);

      return '$formattedDate ${GlobalsStyle.dotSeparator} $tagValue';

    }).toList();

  }

}
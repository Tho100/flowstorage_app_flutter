import 'package:flowstorage_fsc/helper/format_date.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:mysql_client/mysql_client.dart';

class DateGetterPs {

  final userData = GetIt.instance<UserDataProvider>();

  Future<List<String>> myGetDateParams(MySQLConnectionPool conn, String tableName) async {

    final selectUploadDate = 'SELECT UPLOAD_DATE, CUST_TAG FROM $tableName WHERE CUST_USERNAME = :username ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';

    final params = {'username': userData.username};
    final retrieveUploadDate = await conn.execute(selectUploadDate,params);

    final storeDateValues = <String>[];

    for (final res in retrieveUploadDate.rows) {

      final dateValue = res.assoc()['UPLOAD_DATE']!;
      final tagValue = res.assoc()['CUST_TAG']!;

      final formattedDate = FormatDate().formatDifference(dateValue);

      storeDateValues.add('$formattedDate ${GlobalsStyle.dotSeperator} $tagValue');

    }

    return storeDateValues;

  }

  Future<List<String>> getDateParams(MySQLConnectionPool conn, String tableName) async {
    
    final selectUploadDate = 'SELECT UPLOAD_DATE, CUST_TAG FROM $tableName ORDER BY STR_TO_DATE(UPLOAD_DATE, "%d/%m/%Y") DESC';
    final retrieveUploadDate = await conn.execute(selectUploadDate);

    final storeDateValues = <String>[];

    for (final res in retrieveUploadDate.rows) {

      final dateValue = res.assoc()['UPLOAD_DATE']!;
      final tagValue = res.assoc()['CUST_TAG']!;

      final formattedDate = FormatDate().formatDifference(dateValue);

      storeDateValues.add('$formattedDate ${GlobalsStyle.dotSeperator} $tagValue');

    }

    return storeDateValues;

  }

}
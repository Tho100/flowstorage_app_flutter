import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:intl/intl.dart';

class DateGetter {

  Future<List<String>> getDateParams(String? username, String? tableName) async {
    

    final conn = await SqlConnection.insertValueParams();

    final selectUploadDate =
        "SELECT UPLOAD_DATE FROM $tableName WHERE CUST_USERNAME = :username";

    final params = {'username': username};
    final retrieveUploadDate = await conn.execute(selectUploadDate, params);

    final storeDateValues = <String>[];

    for (final res in retrieveUploadDate.rows) {

      final dateValue = res.assoc()['UPLOAD_DATE']!;
      final dateValueWithDashes = dateValue.replaceAll('/', '-');
      final dateComponents = dateValueWithDashes.split('-');

      final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      final formattedDate = DateFormat('MMM d yyyy').format(date);
      storeDateValues.add('$difference days ago ${GlobalsStyle.dotSeperator} $formattedDate');

    }

    
    return storeDateValues;

  }
}
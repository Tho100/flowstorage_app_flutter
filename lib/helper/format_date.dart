import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:intl/intl.dart';

class FormatDate {

  String formatDifference(String dateValue) {

    final dateValueWithDashes = dateValue.replaceAll('/', '-');
    final dateComponents = dateValueWithDashes.split('-');

    final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    final formattedDate = DateFormat('MMM d yyyy').format(date);

    return '$difference days ago ${GlobalsStyle.dotSeparator} $formattedDate';

  }

  String format(String dateValue) {

    final dateValueWithDashes = dateValue.replaceAll('/', '-');
    final dateComponents = dateValueWithDashes.split('-');
    
    final date = DateTime(int.parse(dateComponents[2]), int.parse(dateComponents[1]), int.parse(dateComponents[0]));

    return DateFormat('MMM d yyyy').format(date);

  }

}
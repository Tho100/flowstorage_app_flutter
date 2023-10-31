import 'package:intl/intl.dart';

class DateParser {

  final String date;

  DateParser({required this.date});

  final now = DateTime.now();

  DateTime parse() {

    if(date == "Directory") {
      return now;
    }
    
    if (date.contains('days ago')) {

      int daysAgo = int.parse(date.split(' ')[0]);
      
      return now.subtract(Duration(days: daysAgo));

    } else {
      return DateFormat('MMM dd yyyy').parse(date);
    }
    
  }
  
}
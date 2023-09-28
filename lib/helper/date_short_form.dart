class DateShortForm {

  final String input;

  DateShortForm({required this.input});

  String convert() {
    final Map<String, String> unitConversions = {
      'days': 'd',
      'weeks': 'w',
      'months': 'm',
      'years': 'y',
    };

    List<String> parts = input.split(' ');

    if (parts.length == 3 && parts[0] == '0' && parts[2].toLowerCase() == 'days') {
      return '0d';
    }

    if (parts.length == 2) {
      int? value = int.tryParse(parts[0]);
      String unit = parts[1].toLowerCase();

      if (value != null && unitConversions.containsKey(unit)) {
        if (value == 1) {
          return '1${unitConversions[unit]}';
        } else if (unit == 'days') {
          if (value >= 365) {
            return '${value ~/ 365}${unitConversions['years']}';
          } else if (value >= 30) {
            return '${value ~/ 30}${unitConversions['months']}';
          } else if (value >= 7) {
            return '${value ~/ 7}${unitConversions['weeks']}';
          } else {
            return '$value${unitConversions[unit]}';
          }
        } else if (unit == 'weeks') {
          if (value >= 4) {
            return '${value ~/ 4}${unitConversions['months']}';
          } else {
            return '$value${unitConversions[unit]}';
          }
        } else {
          return '$value${unitConversions[unit]}';
        }
      }
    }

    return input;
  }
}
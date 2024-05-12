import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/cupertino.dart';

class DefaultSwitch extends StatelessWidget {

  final bool value;
  final Function(bool)? onChanged;

  const DefaultSwitch({
    required this.value,
    required this.onChanged,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      thumbColor: ThemeColor.justWhite, 
      activeColor: ThemeColor.darkPurple,
      trackColor: ThemeColor.darkGrey, 
      value: value,
      onChanged: onChanged
    );
  }
  
}
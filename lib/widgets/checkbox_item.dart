import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class CheckBoxItems extends StatelessWidget {

  final int index;
  final Function updateCheckboxState;
  final List<bool> checkedList;

  const CheckBoxItems({
    required this.index,
    required this.updateCheckboxState,
    required this.checkedList,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxTheme(
      data: CheckboxThemeData(
        fillColor: MaterialStateColor.resolveWith(
          (states) => ThemeColor.secondaryWhite,
        ),
        checkColor: MaterialStateColor.resolveWith(
          (states) => ThemeColor.darkPurple,
        ),
        overlayColor: MaterialStateColor.resolveWith(
          (states) => ThemeColor.darkPurple.withOpacity(0.1),
        ),
        side: const BorderSide(
          color: ThemeColor.secondaryWhite,
          width: 2.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
      child: Checkbox(
        value: checkedList[index], 
        onChanged: (bool? value) { 
          updateCheckboxState(index, value!);
        },
      )
    );     
  }

}
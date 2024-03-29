import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/cupertino.dart';
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
    return Transform.scale(
      scale: 1.1,
      child: CheckboxTheme(
        data: CheckboxThemeData(
          fillColor: MaterialStateColor.resolveWith(
            (states) {
              if (states.contains(MaterialState.selected)) {
                return ThemeColor.darkPurple;
              } else {
                return ThemeColor.darkBlack; 
              }
            },
          ),
          checkColor: MaterialStateColor.resolveWith(
            (states) => ThemeColor.darkBlack,
          ),
          side: const BorderSide(
            color: ThemeColor.secondaryWhite,
            width: 2.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        child: Checkbox(
          value: checkedList[index], 
          onChanged: (bool? value) { 
            updateCheckboxState(index, value!);
          },
        )
      ),
    );     
  }

}
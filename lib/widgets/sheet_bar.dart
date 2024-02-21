import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class BottomsheetBar extends StatelessWidget {

  const BottomsheetBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 35,
        height: 5,
        decoration: BoxDecoration(
          color: ThemeColor.darkWhite,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }

}
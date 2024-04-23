import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class AlertDialogWidget extends StatelessWidget {
    
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  const AlertDialogWidget({
    this.title,
    this.content,
    this.actions,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14)
      ),
      backgroundColor: ThemeColor.mediumBlack,
      title: title,
      content: content,
      actions: actions,
    );
  }
  
}
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class InteractDialog {

  Future buildDialog({
    required BuildContext context,
    required List<Widget> children
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)
          ),
          backgroundColor: ThemeColor.mediumBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: children
          )
        );
      }
    );
  }

}
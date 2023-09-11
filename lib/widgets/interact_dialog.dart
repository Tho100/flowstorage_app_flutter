import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class InteractDialog {

  Future buildDialog({
    required BuildContext context,
    required List<Widget> childrenWidgets
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          backgroundColor: ThemeColor.darkBlack,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: childrenWidgets
          )
        );
      }
    );
  }

}
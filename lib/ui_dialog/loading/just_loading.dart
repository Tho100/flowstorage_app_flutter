import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/alert_dialog_widget.dart';
import 'package:flutter/material.dart';

class JustLoading {
  
  late BuildContext context;

  Future<void> startLoading({required BuildContext context}) {
    
    this.context = context;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => buildLoadingDialog(),
    );
    
  }

  void stopLoading() {
    Navigator.pop(context);
  }

  AlertDialogWidget buildLoadingDialog() {
    
    const color = ThemeColor.darkPurple;

    return const AlertDialogWidget(
      content: SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(color: color),
        ),
      ),
    );
  }

}
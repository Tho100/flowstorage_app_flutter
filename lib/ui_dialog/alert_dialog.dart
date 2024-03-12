import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog {

  static Future alertDialog(String messages) {
    return showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)
          ),
          backgroundColor: ThemeColor.mediumBlack,
          content: Text(messages,
            style: const TextStyle(
              color: ThemeColor.justWhite,
              fontWeight: FontWeight.w500,
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                style: TextStyle(
                  color: ThemeColor.secondaryWhite,
                  fontWeight: FontWeight.bold,
                )
              ),
            ),
          ],
        );
      },
    );
  }

  static Future alertDialogTitle(String title, String messages) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: ThemeColor.mediumBlack,
          title: Text(title,
            style: const TextStyle(
              color: ThemeColor.justWhite
            )
          ),
          content: Text(messages,
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w500,
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK',
                style: TextStyle(
                  color: ThemeColor.secondaryWhite,
                  fontWeight: FontWeight.bold,
                )
              ),
            ),
          ],
        );
      },
    );
  }

  static Future alertDialogCustomOnPressed({
    required String messages, 
    required VoidCallback oPressedEvent, 
    required VoidCallback onCancelPressed,
    required BuildContext context
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)
          ),
          backgroundColor: ThemeColor.mediumBlack,
          content: Text(messages,
            style: const TextStyle(
              color: ThemeColor.justWhite,
              fontWeight: FontWeight.w500,
            )
          ),
          actions: [
            TextButton(
              onPressed: onCancelPressed,
              child: const Text('Cancel',
                style: TextStyle(
                  color: ThemeColor.secondaryWhite,
                  fontWeight: FontWeight.bold,
                )
              ),
            ),
            TextButton(
              onPressed: oPressedEvent,
              child: const Text('Confirm',
                style: TextStyle(
                  color: ThemeColor.darkPurple,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
          ],
        );
      },
    );
  }

}
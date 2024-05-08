import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/alert_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAlertDialog {

  static Future alertDialog(String messages) {
    return showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialogWidget(
          content: Text(messages,
            style: GoogleFonts.inter(
              color: ThemeColor.justWhite,
              fontWeight: FontWeight.w800,
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK',
                style: GoogleFonts.inter(
                  color: ThemeColor.secondaryWhite,
                  fontWeight: FontWeight.w800,
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
        return AlertDialogWidget(
          title: Text(title,
            style: GoogleFonts.inter(
              color: ThemeColor.justWhite,
              fontWeight: FontWeight.w800,
            )
          ),
          content: Text(messages,
            style: GoogleFonts.inter(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w800,
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK',
                style: GoogleFonts.inter(
                  color: ThemeColor.secondaryWhite,
                  fontWeight: FontWeight.w800,
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
        return AlertDialogWidget(
          content: Text(messages,
            style: GoogleFonts.inter(
              color: ThemeColor.justWhite,
              fontWeight: FontWeight.w800,
            )
          ),
          actions: [

            TextButton(
              onPressed: onCancelPressed,
              child: Text('Cancel',
                style: GoogleFonts.inter(
                  color: ThemeColor.secondaryWhite,
                  fontWeight: FontWeight.w800,
                )
              ),
            ),

            TextButton(
              onPressed: oPressedEvent,
              child: Text('Confirm',
                style: GoogleFonts.inter(
                  color: ThemeColor.darkPurple,
                  fontWeight: FontWeight.w800
                )
              ),
            ),
            
          ],
        );
      },
    );
  }

}
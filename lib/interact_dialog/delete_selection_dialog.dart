import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/alert_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteSelectionDialog {
  
  Future buildDeleteSelectionDialog({
    required String appBarTitle,
    required VoidCallback deleteOnPressed
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialogWidget(
          title: Text(
            appBarTitle,
            style: GoogleFonts.inter(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Delete these items? Action is permanent.',
            style: GoogleFonts.inter(
              color: ThemeColor.thirdWhite,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: ThemeColor.secondaryWhite,
                  fontWeight: FontWeight.w800
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.mediumBlack,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                deleteOnPressed();
              },
              child: Text(
                'Delete',
                style: GoogleFonts.inter(
                  color: ThemeColor.darkRed,
                  fontWeight: FontWeight.w800
                ),
              ),
            ),

          ],
        );
      },
    );
  }

}
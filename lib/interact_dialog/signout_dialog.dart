import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/alert_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignOutDialog {
  
  Future<void> buildSignOutDialog({
    required BuildContext context,
    required VoidCallback signOutOnPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialogWidget(
          content: Text(
            'Are you sure you want to sign out from your Flowstorage account?',
            style: GoogleFonts.inter(
              color: ThemeColor.justWhite,
              fontWeight: FontWeight.w800
            ),
          ),
          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: ThemeColor.secondaryWhite,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.mediumBlack,
                elevation: 0,
              ),
              onPressed: signOutOnPressed,
              child: Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  color: ThemeColor.darkRed,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

          ],
        );
      },
    );
  }
  
}
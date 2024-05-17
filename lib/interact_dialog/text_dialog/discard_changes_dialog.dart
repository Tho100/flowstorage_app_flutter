import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/alert_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscardChangesDialog {

  Future<bool> buildConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialogWidget(
          content: Text("Discard changes?",
            style: GoogleFonts.inter(
              color: ThemeColor.justWhite,
              fontWeight: FontWeight.w800
            )
          ),
          actions: [

            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel',
                style: GoogleFonts.inter(
                  color: ThemeColor.secondaryWhite,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Discard',
                style: GoogleFonts.inter(
                  color: ThemeColor.darkPurple,
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
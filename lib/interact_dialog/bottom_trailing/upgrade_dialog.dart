import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UpgradeDialog {

  static Future buildUpgradeBottomSheet({
    required String message,
    required BuildContext context
  }) {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.justWhite,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return Column(
          children: [
            
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text("Upgrade Account",
                style: GoogleFonts.poppins(
                  color: ThemeColor.darkGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 22
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: MediaQuery.of(context).size.width-55,
              child: Text(message,
                style: GoogleFonts.poppins(
                  color: ThemeColor.darkGrey,
                  fontWeight: FontWeight.w600,
                  fontSize: 18
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 198),

            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width-55,
                height: 65,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColor.darkBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    )
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    NavigatePage.goToPageUpgrade();
                  },
                  child: const Text(
                    'Upgrade',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: ThemeColor.justWhite,
                    ),
                  ),
                ),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No Thanks",
                style: TextStyle(
                  color: ThemeColor.thirdWhite,
                  fontSize: 16,
                ),
              ),
            ),
            
          ],
        );
      },
    );
  }

}
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackAlert {

  static final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> errorSnack(String message) {
    return scaffoldMessenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ThemeColor.darkRed,
        duration: const Duration(seconds: 2),
        content: Row( 
          children: [
            const Icon(Icons.close,color: Colors.white),
            const SizedBox(width: 10),
            SizedBox(
              width: 320,
              child: Text(message, 
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis
              ),
            ),
          ],
        ),
      )
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> okSnack({
    required String message,
    IconData? icon
  }) {
    return scaffoldMessenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ThemeColor.justWhite,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            if (icon != null) Icon(icon, color: ThemeColor.mediumBlack, size: 16),
            if (icon != null) const SizedBox(width: 10),
            SizedBox(
              width: 320,
              child: Text(message,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ThemeColor.mediumBlack,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis
              ),
            ),
          ],
        ),
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> upgradeSnack() {
    return scaffoldMessenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color.fromARGB(255, 216, 142, 46),
        duration: const Duration(seconds: 6),
        content: Row(
          children: [
            const Text("(Warning) Storage usage exceeded 70%."), 
            const Spacer(),
            TextButton(
              onPressed: () => NavigatePage.goToPageUpgrade(),
              child: const Text('Upgrade'),
            ),
          ],
        ),
      ),
    );
  } 

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> uploadingSnack({
    required String message
  }) {
    return scaffoldMessenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ThemeColor.justWhite,
        content: SizedBox(
          width: 320,
          child: Text(message,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: ThemeColor.mediumBlack,
              fontWeight: FontWeight.w800,
            ), 
            overflow: TextOverflow.ellipsis
          ),
        ),
        action: SnackBarAction(
          textColor: ThemeColor.mediumBlack,
          label: "Cancel",
          onPressed: () {}
        ),
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> temporarySnack({
    required String message
  }) {
    return scaffoldMessenger.showSnackBar(
      SnackBar(        
        behavior: SnackBarBehavior.floating,
        backgroundColor: ThemeColor.justWhite,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check, color: ThemeColor.mediumBlack, size: 16),
            const SizedBox(width: 10),
            SizedBox(
              width: 320,
              child: Text(message, 
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ThemeColor.mediumBlack,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis
              ),
            ),
          ],
        ),
      )
    );
  }

  static void stop() {
    scaffoldMessenger.hideCurrentSnackBar();
  }

}
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class SnackAlert {

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> errorSnack(String message) {

    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

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

    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

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
                style: const TextStyle(color: ThemeColor.mediumBlack),
                overflow: TextOverflow.ellipsis
              ),
            ),
          ],
        ),
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> upgradeSnack() {

    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

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
              onPressed: () {
                NavigatePage.goToPageUpgrade();
              },
              child: const Text('Upgrade'),
            ),
          ],
        ),
      ),
    );
  } 

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> uploadingSnack({
    required ScaffoldMessengerState snackState, 
    required String message
  }) {
    return snackState.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ThemeColor.justWhite,
        content: Row(
          children: [
            SizedBox(
              width: 320,
              child: Text(message,
                style: const TextStyle(color: ThemeColor.mediumBlack), 
                overflow: TextOverflow.ellipsis
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () async { },
              child: const Text('Cancel',
                style: TextStyle(color: ThemeColor.mediumBlack),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> temporarySnack({
    required ScaffoldMessengerState snackState, 
    required String message
  }) {
    return snackState.showSnackBar(
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
                style: const TextStyle(color: ThemeColor.mediumBlack),
                overflow: TextOverflow.ellipsis
              ),
            ),
          ],
        ),
      )
    );
  }

}
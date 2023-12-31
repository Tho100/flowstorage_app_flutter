import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class SnakeAlert {

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> errorSnake(String message) {

    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);
    return scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row( 
          children: [
            const Icon(Icons.close,color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
        ],
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: ThemeColor.darkRed,
      )
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> okSnake({
    required String message,
    IconData? icon
  }) {
    
    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);
    return scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.white, size: 16),
            if (icon != null) const SizedBox(width: 10),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: ThemeColor.mediumGrey,
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> upgradeSnake() {

    final scaffoldMessenger = ScaffoldMessenger.of(navigatorKey.currentContext!);

    return scaffoldMessenger.showSnackBar(
      SnackBar(
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
        duration: const Duration(seconds: 6),
        backgroundColor: const Color.fromARGB(255, 216, 142, 46),
      ),
    );
    
  } 

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> uploadingSnake({
    required ScaffoldMessengerState snackState, 
    required String message
  }) {
    return snackState.showSnackBar(
      SnackBar(
        backgroundColor: ThemeColor.mediumGrey,
        content: Row(
          children: [
            Text(message), 
            const Spacer(),
            TextButton(
              onPressed: () async { },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> temporarySnake({
    required ScaffoldMessengerState snackState, 
    required String message
  }) {
    return snackState.showSnackBar(
      SnackBar(        
        content: Row(
          children: [
            const Icon(Icons.check, color: Colors.white, size: 16),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: ThemeColor.mediumGrey,
      )
    );
  }

}
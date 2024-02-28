import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class SignOutDialog {
  
  Future<void> buildSignOutDialog({
    required BuildContext context,
    required VoidCallback signOutOnPressed,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)
          ),
          backgroundColor: ThemeColor.mediumBlack,
          content: const Text(
            'Are you sure you want to sign out from your Flowstorage account?',
            style: TextStyle(color: ThemeColor.justWhite),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: ThemeColor.justWhite),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.mediumBlack,
                elevation: 0,
              ),
              onPressed: signOutOnPressed,
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  
}
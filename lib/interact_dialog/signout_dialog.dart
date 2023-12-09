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
            borderRadius: BorderRadius.circular(12)
          ),
          backgroundColor: ThemeColor.darkGrey,
          content: const Text(
            'Logout from your Flowstorage account? Your offline files will be deleted.',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.darkGrey,
                elevation: 0,
              ),
              onPressed: signOutOnPressed,
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  
}
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class DeleteAccountDialog {
  
  Future<void> buildDeleteAccountDialog({
    required VoidCallback deleteOnPressed
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          backgroundColor: ThemeColor.darkGrey,
          content: const Text(
            'Delete your Flowstorage account? This action is irreversible.',
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
              onPressed: deleteOnPressed,
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
  
}
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class DeleteSelectionDialog {
  
  Future buildDeleteSelectionDialog({
    required BuildContext context,
    required String appBarTitle,
    required VoidCallback deleteOnPressed
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          ),
          backgroundColor: ThemeColor.darkGrey,
          title: Text(
            appBarTitle,
            style: const TextStyle(
              color: ThemeColor.justWhite,
            ),
          ),
          content: const Text(
            'Delete these items? Action is permanent.',
            style: TextStyle(color: ThemeColor.secondaryWhite),
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
              onPressed: () {
                Navigator.pop(context);
                deleteOnPressed();
              },
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
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class DeleteDialog {

  Future buildDeleteDialog({
    required String fileName,
    required VoidCallback onDeletePressed,
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)
          ),
          backgroundColor: ThemeColor.mediumBlack,
          title: Text(fileName,
            style: const TextStyle(
              color: ThemeColor.justWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: const Text(
            'Delete this item? Action is permanent.',
            style: TextStyle(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: ThemeColor.secondaryWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColor.mediumBlack,
                elevation: 0,
              ),
              onPressed: () async {
                Navigator.pop(context);
                onDeletePressed();
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: ThemeColor.darkRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
}
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/alert_dialog_widget.dart';
import 'package:flutter/material.dart';

class DeleteDialog {

  Future buildDeleteDialog({
    required String fileName,
    required VoidCallback onDeletePressed,
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialogWidget(
          title: Text(fileName,
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Delete this item? Action is permanent.',
            style: TextStyle(
              color: ThemeColor.thirdWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
              onPressed: () {
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
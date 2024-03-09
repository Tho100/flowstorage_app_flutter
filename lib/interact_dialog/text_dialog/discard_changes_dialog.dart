import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class DiscardChangesDialog {

  Future<bool> buildConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: ThemeColor.mediumBlack,
          content: const Text("Discard changes?",
            style: TextStyle(
              color: ThemeColor.justWhite,
              fontWeight: FontWeight.w500
            )
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel',
                style: TextStyle(
                  color: ThemeColor.secondaryWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard',
                style: TextStyle(
                  color: ThemeColor.darkPurple,
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
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_dialog_button.dart';
import 'package:flutter/material.dart';

class RenameFolderDialog {
  
  static final folderRenameController = TextEditingController();

  Future<void> buildRenameFolderDialog({
    required String folderName,
    required VoidCallback renameFolderOnPressed
  }) async {
    return InteractDialog().buildDialog(
      context: navigatorKey.currentContext!,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 18.0, right: 18.0, top: 16.0),
          child: Text(
            folderName,
            style: const TextStyle(
              color: ThemeColor.justWhite,
              fontSize: 17,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
    
        const Divider(color: ThemeColor.lightGrey),

        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 6.0, top: 6.0),
          child: TextFormField(
            autofocus: true,
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w500,
            ),
            enabled: true,
            controller: folderRenameController,
            decoration: GlobalsStyle.setupTextFieldDecoration("Enter new name"),
          ),
        ),

        const SizedBox(height: 5),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            const SizedBox(width: 5),

            MainDialogButton(
              text: "Cancel",
              onPressed: () {
                folderRenameController.clear();
                Navigator.pop(navigatorKey.currentContext!);
              },
              isButtonClose: true,
            ),
              
            const SizedBox(width: 10),

            MainDialogButton(
              text: "Rename",
              onPressed: () {
                renameFolderOnPressed();
                Navigator.pop(navigatorKey.currentContext!);
              },
              isButtonClose: false,
            ),
              
            const SizedBox(width: 18),
          ],
        ),
        const SizedBox(height: 15),
      ]
    );
  }
  
}
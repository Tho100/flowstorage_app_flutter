import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_dialog_button.dart';
import 'package:flutter/material.dart';

class CreateDirectoryDialog {
  
  static final directoryNameController = TextEditingController();

  Future buildCreateDirectoryDialog({
    required BuildContext context,
    required VoidCallback createOnPressed
  }) {
    return InteractDialog().buildDialog(
      context: context,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 2.0, left: 18.0, right: 18.0, top: 16.0),
              child: Text(
                "Create new directory",
                style: TextStyle(
                  color: ThemeColor.justWhite,
                  fontSize: 17,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 5),

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
            maxLength: 50,
            controller: directoryNameController,
            decoration: GlobalsStyle.setupTextFieldDecoration("Enter directory name"),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            
            const SizedBox(width: 5),

            MainDialogButton(
              text: "Cancel",
              onPressed: () {
                directoryNameController.clear();
                Navigator.pop(context);
              },
              isButtonClose: true,
            ),
            
            const SizedBox(width: 10),

            MainDialogButton(
              text: "Create",
              onPressed: () async {
                createOnPressed();
                Navigator.pop(context);
              },
              isButtonClose: false,
            ),
            
            const SizedBox(width: 18),
          ],
        ),
        const SizedBox(height: 12)
      ]
    );
  }

}
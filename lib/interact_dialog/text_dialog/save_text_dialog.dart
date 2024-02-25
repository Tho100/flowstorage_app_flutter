import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_dialog_button.dart';
import 'package:flutter/material.dart';

class SaveTextDialog {

  Future buildSaveTextDialog({
    required TextEditingController fileNameController,
    required VoidCallback saveOnPressed,
    required BuildContext context
  }) {
    return InteractDialog().buildDialog(
      context: context, 
      childrenWidgets: <Widget>[
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0, left: 18.0, right: 18.0, top: 16.0),
              child: Text(
                "Save Text File",
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

        const Divider(color: ThemeColor.lightGrey),

        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 6.0, top: 6.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1.0, color: ThemeColor.mediumBlack),
            ),
            child: TextFormField(
              autofocus: true,
              style: const TextStyle(color: ThemeColor.justWhite),
              enabled: true,
              controller: fileNameController,
              decoration: GlobalsStyle.setupTextFieldDecoration("Untitled text file")
            ),
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
                fileNameController.clear();
                Navigator.pop(context);
              }, 
              isButtonClose: true
            ),
            
            const SizedBox(width: 10),
            
            MainDialogButton(
              text: "Save", 
              onPressed: saveOnPressed,
              isButtonClose: false
            ),
            
            const SizedBox(width: 18),
          ],
        ),
        const SizedBox(height: 12),
      ]
    );
  }

}
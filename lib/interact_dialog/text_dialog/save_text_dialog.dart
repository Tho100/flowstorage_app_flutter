import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_dialog_button.dart';
import 'package:flowstorage_fsc/widgets/text_field/main_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SaveTextDialog {

  Future buildSaveTextDialog({
    required TextEditingController fileNameController,
    required VoidCallback saveOnPressed,
    required BuildContext context
  }) {
    return InteractDialog().buildDialog(
      context: context, 
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 18.0, right: 18.0, top: 16.0),
              child: Text(
                "Save Text File",
                style: GoogleFonts.inter(
                  color: ThemeColor.secondaryWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
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
              border: Border.all(
                color: ThemeColor.mediumBlack
              ),
            ),
            child: MainTextField(
              hintText: "Untitled text file",
              autoFocus: true,
              maxLength: 40,
              controller: fileNameController,
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
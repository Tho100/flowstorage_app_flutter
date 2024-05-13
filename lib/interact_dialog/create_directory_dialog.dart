import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_dialog_button.dart';
import 'package:flowstorage_fsc/widgets/text_field/main_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateDirectoryDialog {
  
  static final directoryNameController = TextEditingController();

  Future buildCreateDirectoryDialog({
    required BuildContext context,
    required VoidCallback createOnPressed
  }) {
    return InteractDialog().buildDialog(
      context: context,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0, left: 18.0, right: 18.0, top: 16.0),
              child: Text(
                "Create new directory",
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

        const SizedBox(height: 5),

        const Divider(color: ThemeColor.lightGrey),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6.0),
          child: MainTextField(
            hintText: "Enter directory name",
            autoFocus: true,
            controller: directoryNameController,
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
              onPressed: () {
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
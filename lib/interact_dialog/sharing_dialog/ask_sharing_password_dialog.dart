import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/sharing_query/share_file_data.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_dialog_button.dart';
import 'package:flutter/material.dart';

class SharingPassword {

  final sharingPasswordController = TextEditingController();
  
  Future buildAskPasswordDialog({
    required String sendTo, 
    required String fileName, 
    required String comment, 
    required String authInput,
    required dynamic fileData, 
    required dynamic thumbnail,
    required BuildContext? context
  }) {
    return InteractDialog().buildDialog(
      context: context!, 
      children: [

        const Padding(
          padding: EdgeInsets.only(bottom: 8.0, left: 18.0, right: 18.0, top: 16.0),
          child: Text(
            "Enter this user sharing password",
            style: TextStyle(
              color: ThemeColor.secondaryWhite,
              fontSize: 17,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: 5),

        const Divider(color: ThemeColor.lightGrey),

        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ThemeColor.mediumBlack
              ),
            ),
            child: TextFormField(
              style: const TextStyle(
                color: ThemeColor.justWhite,
                fontWeight: FontWeight.w500,
              ),
              enabled: true,
              controller: sharingPasswordController,
              decoration: GlobalsStyle.setupTextFieldDecoration("Enter password")
            ),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            
            const SizedBox(width: 5),

            MainDialogButton(
              text: "Close",
              onPressed: () {
                sharingPasswordController.clear();
                Navigator.pop(context);
              },
              isButtonClose: true,
            ),
            
            const SizedBox(width: 10),

            MainDialogButton(
              text: "Share",
              isButtonClose: false,
              onPressed: () async {

                final loadingDialog = SingleTextLoading();
                final hashedPassword = AuthModel().computeAuth(sharingPasswordController.text);

                if(hashedPassword == authInput) {
                  
                  loadingDialog.startLoading(
                    title: "Sharing...", context: context
                  );

                  await ShareFileData().insertValuesParams(
                    sendTo: sendTo, 
                    fileName: fileName, 
                    comment: comment, 
                    fileData: fileData, 
                    thumbnail: thumbnail
                  );

                } else {
                  CustomAlertDialog.alertDialogTitle("Sharing failed", "Entered password is incorrect.");
                }
                
                loadingDialog.stopLoading();

                Navigator.pop(context);

              },
            ),
            
            const SizedBox(width: 18),

          ],
        ),
        
        const SizedBox(height: 15),

      ],
    );  
  }
}
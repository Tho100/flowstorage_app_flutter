import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/sharing_query/share_file_data.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/main_dialog_button.dart';
import 'package:flutter/material.dart';

class SharingPassword {

  final sharingPasswordController = TextEditingController();
  final shareFileData = ShareFileData();

  Future buildAskPasswordDialog({
    required String sendTo, 
    required String fileName, 
    required String comment, 
    required String fileType, 
    required String authInput,
    required dynamic fileData, 
    required dynamic thumbnail,
    required BuildContext? context
  }) {

    return InteractDialog().buildDialog(
      context: context!, 
      childrenWidgets: <Widget>[

        const Padding(
          padding: EdgeInsets.only(bottom: 8.0, left: 18.0, right: 18.0, top: 16.0),
          child: Text(
            "Enter this user sharing password",
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 17,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w500,
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
              border: Border.all(width: 1.0, color: ThemeColor.darkGrey),
            ),
            child: TextFormField(
              style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
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
              onPressed: () async {

                final loadingDialog = SingleTextLoading();
                final compare = AuthModel().computeAuth(sharingPasswordController.text);

                if(compare == authInput) {
                  
                  loadingDialog.startLoading(
                    title: "Sharing...", context: context);

                  shareFileData.insertValuesParams(
                    sendTo: sendTo, 
                    fileName: fileName, 
                    comment: comment, 
                    fileData: fileData, 
                    fileType: fileType, 
                    thumbnail: thumbnail
                  );

                } else {
                  CustomAlertDialog.alertDialogTitle("Sharing failed", "Entered password is incorrect.");
                }
                
                loadingDialog.stopLoading();

                Navigator.pop(context);
              },
              isButtonClose: false,
            ),
            
            const SizedBox(width: 18),
          ],
        ),
        
        const SizedBox(height: 15),

      ],
    );  
  }
}
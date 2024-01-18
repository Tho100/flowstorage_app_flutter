import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/add_password_sharing.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class AddSharingPassword {

  final userData = GetIt.instance<UserDataProvider>();
  
  final addPasswordController = TextEditingController();

  Future buildAddPasswordDialog() {
    return InteractDialog().buildDialog(
      context: navigatorKey.currentContext!, 
      childrenWidgets: <Widget>[
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0, left: 18.0, right: 18.0, top: 16.0),
              child: Text(
                "Password for File Sharing",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
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
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 6.0, top: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(width: 1.0, color: ThemeColor.darkBlack),
            ),
            child: TextFormField(
              style: const TextStyle(color: ThemeColor.justWhite),
              enabled: true,
              maxLength: 90,
              controller: addPasswordController,
              decoration: GlobalsStyle.setupTextFieldDecoration("Enter password")
            ),
          ),
        ),

        const SizedBox(height: 5),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            const SizedBox(width: 5),

            MainDialogButton(
              text: "Close", 
              onPressed: () {
                addPasswordController.clear();
                Navigator.pop(navigatorKey.currentContext!);
              }, 
              isButtonClose: true
            ),
              
            const SizedBox(width: 10),

            MainDialogButton(
              text: "Confirm",
              onPressed: () async {

                try {

                  if(addPasswordController.text.isEmpty) {
                    return;
                  }

                  await UpdatePasswordSharing().update(
                    username: userData.username, 
                    newAuth: addPasswordController.text
                  );

                  CustomAlertDialog.alertDialogTitle("Added password for File Sharing", "Users are required to enter the password before they can share a file with you.");

                } catch (err, st) {
                  Logger().e("Exception from _buildAddPassword {settings_page}", err, st);
                  CustomAlertDialog.alertDialogTitle("An error occurred", "Faild to add/update pasword for File Sharing. Please try again later.");
                }

              },
              isButtonClose: false,
            ),

            const SizedBox(width: 18),
          ],
        ),
        
        const SizedBox(height: 12),

      ]
    );
  }
  
}
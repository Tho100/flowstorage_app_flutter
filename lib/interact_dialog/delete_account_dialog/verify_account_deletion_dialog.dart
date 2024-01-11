import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_classes/user_data_retriever.dart';
import 'package:flowstorage_fsc/data_query/delete_data.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/interact_dialog/delete_account_dialog/delete_account_dialog.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/models/local_storage_model.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class VerifyAccountDeletionDialog {

  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();

  final pinController = TextEditingController();

  Future buildVerifyAccountDeletionDialog() {
    return InteractDialog().buildDialog(
      context: navigatorKey.currentContext!, 
      childrenWidgets: <Widget>[
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0, left: 18.0, right: 18.0, top: 16.0),
              child: Text(
                "Verify your PIN to proceed",
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
              maxLength: 3,
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: GlobalsStyle.setupTextFieldDecoration("Enter your PIN")
            ),
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
                pinController.clear();
                Navigator.pop(navigatorKey.currentContext!);
              }, 
              isButtonClose: true
            ),
              
            const SizedBox(width: 10),

            MainDialogButton(
              text: "Confirm",
              onPressed: () async {

                try {

                  if(pinController.text.isEmpty) {
                    return;
                  }

                  final isAccountDeleted = await confirmOnPressed();

                  if(isAccountDeleted) {
                    NavigatePage.permanentPageMain(
                      navigatorKey.currentContext!
                    );
                  }

                } catch (err, st) {
                  Logger().e("Exception from _buildAddPassword {settings_page}", err, st);
                  CustomAlertDialog.alertDialogTitle("An error occurred", "Please try again later.");
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

  Future<bool> confirmOnPressed() async {

    bool isSuceededPhase2 = false;

    final conn = await SqlConnection.initializeConnection();

    final getPin = await UserDataRetriever().retrieveAccountAuthentication(conn: conn, username: userData.username);

    final userPin = getPin["pin"];

    final pinInput = pinController.text;
    final hashedPinInput = AuthModel().computeAuth(pinInput);

    if(hashedPinInput == userPin) {
      await DeleteAccountDialog().buildDeleteAccountDialog(
        deleteOnPressed: () async {
          final isPhase1Succeeded = await deleteOnPressed();
          if(isPhase1Succeeded) {
            isSuceededPhase2 = true;
            Navigator.pop(navigatorKey.currentContext!);
          }
        }
      );

    } else {
      CustomAlertDialog.alertDialog("Entered PIN Is incorrect.");
      isSuceededPhase2 = false;

    }

    return isSuceededPhase2;

  }

  Future<bool> deleteOnPressed() async {

    bool isSuceededPhase1 = false;

    final loading = SingleTextLoading();

    loading.startLoading(
      title: "Deleting...", context: navigatorKey.currentContext!);

    try {

      await DeleteData().deleteAccount();
      await LocalStorageModel()
        .deleteAutoLoginAndOfflineFiles(userData.username, true);

      clearUserStorageData();

      isSuceededPhase1 = true;

    } catch (err) {
      isSuceededPhase1 = false;
    }

    loading.stopLoading();

    return isSuceededPhase1;

  }

  void clearUserStorageData() {

    storageData.fileNamesList.clear();
    storageData.fileNamesFilteredList.clear();
    storageData.fileDateList.clear();
    storageData.imageBytesList.clear();
    storageData.imageBytesFilteredList.clear();
    tempStorageData.folderNameList.clear();

    userData.setUsername('');
    userData.setEmail('');
    userData.setSharingPasswordStatus('');
    userData.setSharingStatus('');

  }

}
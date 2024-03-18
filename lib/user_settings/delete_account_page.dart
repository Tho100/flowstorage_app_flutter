import 'package:flowstorage_fsc/data_query/delete_data.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/interact_dialog/delete_account_dialog.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/models/local_storage_model.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';
import 'package:flowstorage_fsc/widgets/text_field/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/verify_auth.dart';
import 'package:get_it/get_it.dart';

class DeleteAccountPage extends StatelessWidget {

  DeleteAccountPage({Key? key}) : super(key: key);

  final pinController = TextEditingController();
  final passwordController = TextEditingController();

  final passwordNotifier = ValueNotifier<bool>(false);

  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();

  Widget buildBody(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);

    return Column(
      children: [
        
        const Padding(
          padding: EdgeInsets.only(left: 28.0),
          child: HeaderText(
            title: "Remove Account", 
            subTitle: "Delete your account data & information"
          ),
        ),

        const SizedBox(height: 35),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            AuthTextField(mediaQuery).passwordTextField(
              controller: passwordController, 
              visibility: passwordNotifier,
              customText: "Enter your password"
            ),
            
            const SizedBox(width: 6),

            AuthTextField(mediaQuery).pinTextField(
              controller: pinController
            ),

          ],
        ),

        const SizedBox(height: 20),
        
        MainButton(
          text: "Proceed",
          onPressed: () async {
            await proceedOnPressed(
              pinController.text, 
              passwordController.text
            );
          },
        ),

      ],
    );
  }

  Future<void> proceedOnPressed(String pinInput, String passwordInput) async {

    try {

      final userData = GetIt.instance<UserDataProvider>();

      if(pinInput.isEmpty && passwordInput.isEmpty) {
        return;
      }

      final pinIsIncorrect = await AuthVerification().notEqual(userData.username, AuthModel().computeAuth(pinInput), "CUST_PIN");

      if(pinIsIncorrect) {
        CustomAlertDialog.alertDialog("Entered PIN is incorrect.");
        return;
      }

      final passwordIsIncorrect = await AuthVerification().notEqual(userData.username, AuthModel().computeAuth(passwordInput), "CUST_PASSWORD");

      if(passwordIsIncorrect) {
        CustomAlertDialog.alertDialog("Password is incorrect.");
        return;
      } 

      await DeleteAccountDialog().buildDeleteAccountDialog(
        deleteOnPressed: () async {
          final isAccountDeleted = await deleteOnPressed();
          if(isAccountDeleted) {
            Navigator.pop(navigatorKey.currentContext!);
            NavigatePage.permanentPageMain(
              navigatorKey.currentContext!
            );
          }
        }
      );

    } catch (err) {
      CustomAlertDialog.alertDialogTitle("An error occurred", "Please try again later.");
    }

  }

  Future<bool> deleteOnPressed() async {

    bool succeeded = false;

    final loading = SingleTextLoading();

    loading.startLoading(
      title: "Deleting...", context: navigatorKey.currentContext!);

    try {

      await DeleteData().deleteAccount();

      await LocalStorageModel()
        .deleteAutoLoginAndOfflineFiles(userData.username, true);

      clearUserStorageData();

      succeeded = true;

    } catch (err) {
      succeeded = false;
    }

    loading.stopLoading();

    return succeeded;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context, 
        title: ""
      ).buildAppBar(),
      body: buildBody(context),
    );
  }

}
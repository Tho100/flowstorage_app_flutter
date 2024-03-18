import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/data_classes/user_data_getter.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';
import 'package:flowstorage_fsc/widgets/text_field/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/verify_auth.dart';
import 'package:get_it/get_it.dart';

class BackupRecoveryPage extends StatelessWidget {

  BackupRecoveryPage({Key? key}) : super(key: key);

  final pinController = TextEditingController();
  final passwordController = TextEditingController();

  final passwordNotifier = ValueNotifier<bool>(false);

  Widget buildBody(BuildContext context) {
    
    final mediaQuery = MediaQuery.of(context);

    return Column(
      children: [
        
        const Padding(
          padding: EdgeInsets.only(left: 28.0),
          child: HeaderText(
            title: "Recovery Key", 
            subTitle: "Backup your Recovery Key"
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
          text: "Export Recovery Key",
          onPressed: () async {
            await exportOnPressed(
              pinController.text, 
              passwordController.text
            );
          },
        ),

      ],
    );
  }

  Future<void> exportOnPressed(String pinInput, String passwordInput) async {

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

      final recoveryToken = await UserDataGetter()
        .getRecoveryToken(userData.username);

      final saveBackup = await SaveApi()
        .saveFile(fileName: "FlowstorageRecoveryKey.txt", fileData: recoveryToken);

      CustomFormDialog.startDialog(
        "Recovery key has been backed up",
        "Location path: $saveBackup"
      );

    } catch (err) {
      CustomAlertDialog.alertDialog("Failed to backup your recovery key.");
    }

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
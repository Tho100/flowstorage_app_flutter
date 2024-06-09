import 'package:flowstorage_fsc/data_query/user_data.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';
import 'package:flowstorage_fsc/widgets/text_field/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/verify_auth.dart';
import 'package:get_it/get_it.dart';

class UpdatePasswordPage extends StatefulWidget {

  const UpdatePasswordPage({Key? key}) : super(key: key);

  @override
  UpdatePasswordPageState createState() => UpdatePasswordPageState();
}

class UpdatePasswordPageState extends State<UpdatePasswordPage> {

  final newPasswordController = TextEditingController();
  final passwordController = TextEditingController();
  final pinController = TextEditingController();
  
  final newPasswordNotifier = ValueNotifier<bool>(false);
  final passwordNotifier = ValueNotifier<bool>(false);

  final userData = GetIt.instance<UserDataProvider>();

  Widget buildBody(BuildContext context) {
    
    final mediaQuery = MediaQuery.of(context);

    return Column(
      children: [

        const Padding(
          padding: EdgeInsets.only(left: 28.0),
          child: HeaderText(title: "Change Password", subTitle: "Update your account password"),
        ),
        
        const SizedBox(height: 35),

        AuthTextField(mediaQuery).passwordTextField(
          controller: newPasswordController, 
          visibility: newPasswordNotifier,
          customWidth: mediaQuery.size.width*0.9,
          customText: "Enter new password"
        ),

        const SizedBox(height: 12),

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
          text: "Update", 
          onPressed: () async {
            await processUpdatePassword(
              currentPasswordAuth: passwordController.text, 
              newPasswordAuth: newPasswordController.text, 
              pinAuth: pinController.text
            );
          }
        ),

      ],
    );
  }

  Future<void> processUpdatePassword({
    required String currentPasswordAuth, 
    required String newPasswordAuth, 
    required String pinAuth
  }) async {

    if(newPasswordAuth.isEmpty && currentPasswordAuth.isEmpty) {
      return;
    }

    final passwordIsIncorrect = await AuthVerification()
      .notEqual(userData.username, currentPasswordAuth, "CUST_PASSWORD");
      
    final pinIsIncorrect = await AuthVerification()
      .notEqual(userData.username, pinAuth, "CUST_PIN");
    
    if (!passwordIsIncorrect && !pinIsIncorrect) {

      await UserData()
        .updatePassword(newPassword: newPasswordAuth);

      CustomAlertDialog.alertDialogTitle("Password updated.","Your password has been updated successfully.");

    } else if (passwordIsIncorrect) {
      CustomAlertDialog.alertDialog("Password is incorrect.");

    } else {
      CustomAlertDialog.alertDialog("PIN key is incorrect.");

    }

  }

  @override
  void dispose() {
    passwordController.dispose();
    pinController.dispose();
    newPasswordController.dispose();
    passwordNotifier.dispose();
    newPasswordNotifier.dispose();
    super.dispose();
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

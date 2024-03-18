import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';
import 'package:flowstorage_fsc/widgets/text_field/auth_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';

class ResetPasswordPage extends StatelessWidget {

  final String username;
  final String email;

  ResetPasswordPage({
    required this.username,
    required this.email,
    Key? key
  }) : super(key: key);

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final newPasswordNotifier = ValueNotifier<bool>(false);
  final confirmPasswordNotifier = ValueNotifier<bool>(false);

  Widget buildBody(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);

    return Column(
      children: [
        
        const Padding(
          padding: EdgeInsets.only(left: 28),
          child: HeaderText(
            title: "Account Recovery", 
            subTitle: "Reset your account password"
          ),
        ),

        const SizedBox(height: 35),

        AuthTextField(mediaQuery).passwordTextField(
          controller: newPasswordController, 
          visibility: newPasswordNotifier,
          customText: "Enter a new password"
        ),

        const SizedBox(height: 12),

        AuthTextField(mediaQuery).passwordTextField(
          controller: confirmPasswordController, 
          visibility: confirmPasswordNotifier,
          customText: "Confirm your password"
        ),
        
        const SizedBox(height: 20),

        MainButton(
          text: "Update Password",
          onPressed: () async {
            await processResetPassword(
              currentAuth: confirmPasswordController.text, 
              newAuth: newPasswordController.text
            );
          }
        ),

      ],
    );
  }

  Future<void> processResetPassword({
    required String currentAuth, 
    required String newAuth
  }) async {

    try {

      if(newAuth.isEmpty && currentAuth.isEmpty) {
        return;
      }
      
      if(newAuth != currentAuth) {
        CustomAlertDialog.alertDialog("Password does not match.");
        return;
      }

      final getUsername = await getUsernameByEmail(email);

      await updateAuthPassword(newAuth, getUsername);

      CustomAlertDialog.alertDialogTitle("Password Updated", "Password for $email has been updated. You may login into your account now");

    } catch (err) {
      SnackAlert.errorSnack("Failed to update your password.");
    }
    
  }

  Future<void> updateAuthPassword(String newAuth,String username) async {

    const updateAuthQuery = "UPDATE information SET CUST_PASSWORD = :new_auth WHERE CUST_USERNAME = :username"; 
    final params = {'new_auth': AuthModel().computeAuth(newAuth), 'username': username};

    await Crud().update(query: updateAuthQuery, params: params);

  }

  Future<String> getUsernameByEmail(String custEmail) async {

    const selectUsername = "SELECT CUST_USERNAME FROM information WHERE CUST_EMAIL = :email";
    final params = {'email': custEmail};

    final returnedUsername = await Crud().select(
      query: selectUsername, 
      returnedColumn: "CUST_USERNAME", 
      params: params
    );

    return returnedUsername;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context, 
        title: ""
      ).buildAppBar(),
      body: buildBody(context)
    );
  }

}
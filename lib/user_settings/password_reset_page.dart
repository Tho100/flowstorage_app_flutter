import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

class ResetPasswordPage extends StatefulWidget {

  final String custUsername;
  final String custEmail;

  const ResetPasswordPage({
    Key? key,
    required this.custUsername,
    required this.custEmail,
  }) : super (key: key);

  @override
  State<ResetPasswordPage> createState() => ResetAuthenticationState();
}

class ResetAuthenticationState extends State<ResetPasswordPage> {

  final curPassController = TextEditingController();
  final newPassController = TextEditingController();

  final suffixIconVisibilityNotifier = ValueNotifier<bool>(false);

  Widget _buildTextField(String hintText, TextEditingController controller, BuildContext context, bool isSecured, bool isPin) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: suffixIconVisibilityNotifier,
              builder: (_, isVisible, __) => TextFormField(
                style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                enabled: true,
                controller: controller,
                obscureText: isSecured ? !isVisible : true,
                maxLines: 1,
                decoration: GlobalsStyle.setupTextFieldDecoration(
                  hintText,
                  customSuffix: isSecured 
                    ? IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color.fromARGB(255, 141, 141, 141),
                      ),
                      onPressed: () {
                        suffixIconVisibilityNotifier.value = !isVisible;
                      },
                    )
                  : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {

    return Column(
      children: [
        
        const Padding(
          padding: EdgeInsets.only(left: 28),
          child: HeaderText(title: "Account Recovery", subTitle: "Reset your account password"),
        ),

        const SizedBox(height: 35),

        _buildTextField("Enter a new password", newPassController, context, true, false),

        const SizedBox(height: 12),

        _buildTextField("Confirm your password", curPassController, context, true, false),
        
        const SizedBox(height: 20),

        MainButton(
          text: "Update Password",
          onPressed: () async {
            await processResetPassword(
              currentAuth: curPassController.text, 
              newAuth: newPassController.text
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

      final getUsername = await getUsernameByEmail(widget.custEmail);

      await updateAuthPassword(newAuth, getUsername);

      CustomAlertDialog.alertDialogTitle("Password Updated", "Password for ${widget.custEmail} has been updated. You may login into your account now");

    } catch (err) {
      SnakeAlert.errorSnake("Failed to update your password.");
    }
  }

  Future<void> updateAuthPassword(String newAuth,String username) async {

    const updateAuthQuery = "UPDATE information SET CUST_PASSWORD = :newauth WHERE CUST_USERNAME = :username"; 
    final params = {'newauth': AuthModel().computeAuth(newAuth), 'username': username};

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
  void dispose() {
    newPassController.dispose();
    curPassController.dispose();
    suffixIconVisibilityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
      ),
      body: _buildBody(context)
    );
  }

}
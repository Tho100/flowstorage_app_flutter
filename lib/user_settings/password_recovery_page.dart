import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_classes/user_data_getter.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/user_settings/password_reset_page.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

class PasswordRecoveryPage extends StatefulWidget {

  final String username; 

  const PasswordRecoveryPage({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<PasswordRecoveryPage> createState() => PasswordRecoveryPageState();
}


class PasswordRecoveryPageState extends State<PasswordRecoveryPage> {

  final emailController = TextEditingController();
  final recoveryController = TextEditingController();

  final suffixIconVisibilityNotifier = ValueNotifier<bool>(false);

  Widget _buildTextField(String hintText, TextEditingController mainController, BuildContext context, bool isSecured) {

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
                controller: mainController,
                obscureText: isSecured ? !isVisible : false,
                maxLines: 1,
                maxLength: null,
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
          padding: EdgeInsets.only(left: 28.0),
          child: HeaderText(title: "Reset Password", subTitle: "Reset password with recovery key"),
        ),

        const SizedBox(height: 35),

        _buildTextField("Enter your email address",emailController,context,false),

        const SizedBox(height: 12),

        _buildTextField("Enter your Recovery Key",recoveryController,context,false),

        const SizedBox(height: 20),
        
        MainButton(
          text: "Proceed", 
          onPressed: () async {
            await executeChanges(
              email: emailController.text, 
              recoveryTokenInput: recoveryController.text, 
            );
          }
        ),

      ],
    );
  }

  Future<void> executeChanges({
    required String email, 
    required String recoveryTokenInput, 
  }) async {

    try {

      if(email.isEmpty || recoveryTokenInput.isEmpty) {
        return;
      }

      final conn = await SqlConnection.initializeConnection();

      final username = await UserDataGetter()
        .getUsername(email: email, conn: conn);

      final recoveryToken = await UserDataGetter()
        .getRecoveryToken(username);

      if(recoveryToken != recoveryTokenInput) {
        CustomAlertDialog.alertDialog("Invalid recovery key.");
        return;
      }  

      emailController.clear();
      recoveryController.clear();      

      if(mounted) {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => ResetPasswordPage(
            custUsername: widget.username, custEmail: email
            )
          )
        );
      }

    } catch (err) {
      CustomAlertDialog.alertDialogTitle("An error occurred","Failed to process your recovery key. Please try again later");
    }

  }

  @override
  void dispose() {
    emailController.dispose();
    recoveryController.dispose();
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
      body: _buildBody(context),
    );
  }

}
import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_classes/user_data_getter.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/user_settings/password_reset_page.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Widget buildTextField(String hintText, TextEditingController mainController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextFormField(
              style: GoogleFonts.inter(
                color: ThemeColor.secondaryWhite,
                fontWeight: FontWeight.w800,
              ),
              controller: mainController,
              maxLines: 1,
              maxLength: null,
              decoration: GlobalsStyle.setupTextFieldDecoration(hintText),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      children: [

        const Padding(
          padding: EdgeInsets.only(left: 28.0),
          child: HeaderText(
            title: "Reset Password", 
            subTitle: "Reset password with recovery key"
          ),
        ),

        const SizedBox(height: 35),

        buildTextField("Enter your email address", emailController),

        const SizedBox(height: 12),

        buildTextField("Enter your Recovery Key", recoveryController),

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
            username: widget.username, email: email
            )
          )
        );
      }

    } catch (err) {
      CustomAlertDialog.alertDialogTitle("An error occurred", "Failed to process your recovery key. Please try again later");
    }

  }

  @override
  void dispose() {
    emailController.dispose();
    recoveryController.dispose();
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
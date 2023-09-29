import 'package:flowstorage_fsc/data_classes/user_data_retriever.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/user_settings/password_reset_page.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

class ResetBackup extends StatefulWidget {

  final String username; 

  const ResetBackup({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<ResetBackup> createState() => ResetBackupState();
}


class ResetBackupState extends State<ResetBackup> {

  final emailController = TextEditingController();
  final recoveryController = TextEditingController();
  final sufixIconVisibilityNotifier = ValueNotifier<bool>(false);

  Widget _buildTextField(String hintText, TextEditingController mainController, BuildContext context, bool isSecured) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: sufixIconVisibilityNotifier,
              builder: (_, isVisible, __) => TextFormField(
                style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                enabled: true,
                controller: mainController,
                obscureText: isSecured == true ? !isVisible : false,
                maxLines: 1,
                maxLength: null,
                decoration: GlobalsStyle.setupTextFieldDecoration(
                  hintText,
                  customSuffix: isSecured == true
                  ? IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: const Color.fromARGB(255, 141, 141, 141),
                      ),
                      onPressed: () {
                        sufixIconVisibilityNotifier.value = !isVisible;
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
              recoveryToken: recoveryController.text, 
              context: context
            );
          }
        ),

      ],
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    recoveryController.dispose();
    sufixIconVisibilityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: ThemeColor.darkBlack,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: ThemeColor.darkBlack,
         body: Builder(
          builder: (context) => _buildBody(context),
        ),
      ),
    );
  }

  Future<String> retrieveRecovery(String username) async {

    const selectAuth = "SELECT RECOV_TOK FROM information WHERE CUST_USERNAME = :username";
    final params = {'username': username};

    final returnedAuth = await Crud().select(
      query: selectAuth, 
      returnedColumn: "RECOV_TOK", 
      params: params
    );

    return EncryptionClass().decrypt(returnedAuth);

  }

  Future<void> executeChanges({
    required String email, 
    required String recoveryToken, 
    required BuildContext context
  }) async {

    try {

      if(email.isEmpty || recoveryToken.isEmpty) {
        return;
      }

      final username = await UserDataRetriever().retrieveUsername(email: email);

      if(await retrieveRecovery(username) != recoveryToken) {
        if(!mounted) return;
        CustomAlertDialog.alertDialog("Invalid recovery key.");
        return;
      }  

      emailController.clear();
      recoveryController.clear();      

      if(!mounted) return;
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => 
        ResetAuthentication(custUsername: widget.username, 
                            custEmail: email)));

    } catch (exportBackupFailed) {
      CustomAlertDialog.alertDialogTitle("An error occurred","Failed to export your recovery key. Please try again later");
    }
  }

}
import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/data_classes/user_data_retriever.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/verify_auth.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:get_it/get_it.dart';

class BackupRecovery extends StatelessWidget {

  const BackupRecovery({Key? key}) : super (key: key);
  
  Widget _buildTextField(String hintText, TextEditingController mainController, BuildContext context, bool isSecured, {bool isFromPin = false}) {

    final sufixIconVisibilityNotifier = ValueNotifier<bool>(false);

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
                obscureText: isSecured ? !isVisible : false,
                maxLines: 1,
                maxLength: isFromPin ? 3 : null,
                keyboardType: isFromPin ? TextInputType.number : null,
                decoration: GlobalsStyle.setupTextFieldDecoration(
                  hintText,
                  customSuffix: isSecured
                  ? IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: ThemeColor.thirdWhite,
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
    
    final TextEditingController pinController = TextEditingController();
    final TextEditingController passController = TextEditingController();

    return Column(
      children: [
        
        const Padding(
          padding: EdgeInsets.only(left: 28.0),
          child: HeaderText(title: "Recovery Key",subTitle: "Backup your Recovery Key"),
        ),

        const SizedBox(height: 35),

        _buildTextField("Enter your Password",passController,context,true),

        const SizedBox(height: 15),

        _buildTextField("Enter your PIN",pinController,context,true,isFromPin: true),

        const SizedBox(height: 20),
        
        MainButton(
          text: "Export Recovery Key",
          onPressed: () async {
            await _executeChanges(pinController.text,passController.text, context);
          },
        ),

      ],
    );
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

  Future<void> _executeChanges(String auth0,String auth1, BuildContext context) async {

    try {

      final userData = GetIt.instance<UserDataProvider>();

      if(auth0.isEmpty && auth1.isEmpty) {
        return;
      }

      final pinIsIncorrect = await AuthVerification().notEqual(userData.username, AuthModel().computeAuth(auth0), "CUST_PIN");

      if(pinIsIncorrect) {
        CustomAlertDialog.alertDialog("Entered PIN is incorrect.");
        return;
      }

      final passwordIsIncorrect = await AuthVerification().notEqual(userData.username, AuthModel().computeAuth(auth1), "CUST_PASSWORD");

      if(passwordIsIncorrect) {
        CustomAlertDialog.alertDialog("Password is incorrect.");
        return;

      } 

      final recoveryToken = await UserDataRetriever()
        .retrieveRecoveryToken(userData.username);

      final saveBackup = await SaveApi()
        .saveFile(fileName: "FlowstorageRECOVERYKEY.txt", fileData: recoveryToken);

      CustomFormDialog.startDialog(
        "Recovery key has been backed up",
        "Location path: $saveBackup");

    } catch (err) {
      CustomAlertDialog.alertDialog("Failed to backup your recovery key.");
    }

  }

}
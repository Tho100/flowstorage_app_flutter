import 'package:flowstorage_fsc/api/save_api.dart';
import 'package:flowstorage_fsc/data_classes/user_data_getter.dart';
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
  
  Widget _buildTextField({
    required String hintText, 
    required TextEditingController controller, 
    required BuildContext context, 
    required bool isSecured, 
    required bool isFromPin
  }) {

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
                controller: controller,
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

        _buildTextField(
          hintText: "Enter your password", 
          controller: passController, 
          context: context, 
          isSecured: true,
          isFromPin: false
        ),

        const SizedBox(height: 15),

        _buildTextField(
          hintText: "Enter your PIN", 
          controller: pinController, 
          context: context, 
          isSecured: true, 
          isFromPin: true
        ),

        const SizedBox(height: 20),
        
        MainButton(
          text: "Export Recovery Key",
          onPressed: () async {
            await _exportOnPressed(pinController.text, passController.text);
          },
        ),

      ],
    );
  }

  Future<void> _exportOnPressed(String pinInput, String passwordInput) async {

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
        .saveFile(fileName: "FlowstorageRECOVERYKEY.txt", fileData: recoveryToken);

      CustomFormDialog.startDialog(
        "Recovery key has been backed up",
        "Location path: $saveBackup");

    } catch (err) {
      CustomAlertDialog.alertDialog("Failed to backup your recovery key.");
    }

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
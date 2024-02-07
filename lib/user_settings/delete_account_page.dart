import 'package:flowstorage_fsc/data_query/delete_data.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/interact_dialog/delete_account_dialog/delete_account_dialog.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/models/local_storage_model.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/verify_auth.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:get_it/get_it.dart';

class DeleteAccountPage extends StatelessWidget {

  DeleteAccountPage({Key? key}) : super (key: key);

  final pinController = TextEditingController();
  final passController = TextEditingController();

  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();

  Widget _buildTextField({
    required String hintText, 
    required TextEditingController controller, 
    required BuildContext context, 
    required bool isSecured, 
    required bool isFromPin
  }) {

    final sufixIconVisibilityNotifier = ValueNotifier<bool>(false);

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
    return Column(
      children: [
        
        const Padding(
          padding: EdgeInsets.only(left: 28.0),
          child: HeaderText(title: "Remove Account", subTitle: "Delete your account data & informations"),
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
          text: "Proceed",
          onPressed: () async {
            await _proceedOnPressed(pinController.text, passController.text);
          },
        ),

      ],
    );
  }

  Future<void> _proceedOnPressed(String pinInput, String passwordInput) async {

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
            NavigatePage.permanentPageMain(
              navigatorKey.currentContext!
            );
          }
        }
      );

    } catch (err) {
      CustomAlertDialog.alertDialog("Failed to backup your recovery key.");
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
      appBar: AppBar(
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
      ),
      body: _buildBody(context),
    );
  }

}
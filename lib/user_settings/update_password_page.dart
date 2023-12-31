import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/encryption/verify_auth.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:get_it/get_it.dart';

class UpdatePasswordPage extends StatefulWidget {

  const UpdatePasswordPage({Key? key}) : super(key: key);

  @override
  UpdatePasswordPageState createState() => UpdatePasswordPageState();
}

class UpdatePasswordPageState extends State<UpdatePasswordPage> {

  final newPassController = TextEditingController();
  final curPassController = TextEditingController();
  final curPinController = TextEditingController();
  
  final valueNotifierNew = ValueNotifier<bool>(false);
  final valueNotifierCur = ValueNotifier<bool>(false);

  final userData = GetIt.instance<UserDataProvider>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    curPassController.dispose();
    curPinController.dispose();
    newPassController.dispose();
    valueNotifierCur.dispose();
    valueNotifierNew.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    required BuildContext context,
    required bool isSecured,
    required bool isPin,
    ValueNotifier<bool>? valueNotifier
  }) {

    valueNotifier ??= ValueNotifier<bool>(false); 

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
              valueListenable: valueNotifier,
              builder: (_, isVisible, __) => TextFormField(
                style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                enabled: true,
                controller: controller,
                obscureText: isSecured ? !isVisible : true,
                keyboardType: isPin ? TextInputType.number : TextInputType.text,
                maxLength: isPin ? 3 : 3000,
                maxLines: 1,
                decoration: GlobalsStyle.setupTextFieldDecoration(
                  hintText,
                  customSuffix: isSecured 
                    ? IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        valueNotifier!.value = !isVisible;
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
          child: HeaderText(title: "Change Password", subTitle: "Update your Flowstorage password"),
        ),
        
        const SizedBox(height: 35),

        _buildTextField(
          hintText: "Enter a new password", 
          controller: newPassController, 
          context: context, 
          isSecured: true, 
          isPin: false, 
          valueNotifier: valueNotifierNew
        ),

        const SizedBox(height: 12),

        _buildTextField(
          hintText: "Enter your current password", 
          controller: curPassController, 
          context: context, 
          isSecured: true, 
          isPin: false,
          valueNotifier: valueNotifierCur
        ),
        
        const SizedBox(height: 12),

        _buildTextField(
          hintText: "Enter your current PIN key", 
          controller: curPinController, 
          context: context, 
          isSecured: false, 
          isPin: true
        ),

        const SizedBox(height: 20),

        MainButton(
          text: "Update", 
          onPressed: () async {
            await processUpdatePassword(
              currentAuth: curPassController.text, 
              newAuth: newPassController.text, 
              pinAuth: curPinController.text
            );
          }
        ),

      ],
    );
  }

  Future<void> processUpdatePassword({
    required String currentAuth, 
    required String newAuth, 
    required String pinAuth
  }) async {

    if(newAuth.isEmpty && currentAuth.isEmpty) {
      return;
    }

    final authCase0 = await verifyAuthInput(currentAuth, "CUST_PASSWORD");
    final authCase1 = await verifyAuthInput(pinAuth, "CUST_PIN");
    
    if (!authCase0 && !authCase1) {

      await updateAuthPassword(newPasswordAuth: newAuth);

      CustomAlertDialog.alertDialogTitle("Password updated.","Your pasword has been updated successfully.");

    } else if (authCase0) {
      CustomAlertDialog.alertDialog("Password is incorrect.");

    } else {
      CustomAlertDialog.alertDialog("PIN key is incorrect.");

    }

  }

  Future<bool> verifyAuthInput(String inputStr, String columnName) async {

    return await Verification().notEqual(
      userData.username, 
      AuthModel().computeAuth(inputStr),
      columnName
    );
    
  }

  Future<void> updateAuthPassword({required String newPasswordAuth}) async {

    const updateAuthQuery = "UPDATE information SET CUST_PASSWORD = :newauth WHERE CUST_USERNAME = :username"; 

    final params = {'newauth': AuthModel().computeAuth(newPasswordAuth), 'username': userData.username};
    await Crud().update(query: updateAuthQuery, params: params);

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
        body: _buildBody(context),
      ),
    );
  }

}

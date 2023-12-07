import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/helper/validate_email.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/main_button.dart';
import 'package:flowstorage_fsc/widgets/main_text_field.dart';
import 'package:flutter/material.dart';

import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/data_classes/register_process.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class CakeSignUpPage extends StatefulWidget {
  const CakeSignUpPage({super.key});

  @override
  CakeSignUpPageState createState() => CakeSignUpPageState();
}

class CakeSignUpPageState extends State<CakeSignUpPage> {

  final dateNow = DateFormat('yyyy/MM/dd').format(DateTime.now());

  final visiblePasswordNotifier = ValueNotifier<bool>(false);

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final auth0Controller = TextEditingController();
  final auth1Controller = TextEditingController(); 

  final _locator = GetIt.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    usernameController.clear();
    auth0Controller.clear();
    emailController.clear();
    auth1Controller.clear();
    super.dispose();
  }

  Future<void> insertUserRegistrationInformation({
    required String username,
    required String email,
    required String auth0,
    required String auth1
  }) async {

    try {

      final valueCase0 = AuthModel().computeAuth(auth0);
      final valueCase1 = AuthModel().computeAuth(auth1);
      
      final informationCon = RegisterUser();
      
      await informationCon.insertParams(
        userName: username,
        auth0: valueCase0,
        email: email,
        auth1: valueCase1,
        createdDate: dateNow,
        context: context
      );

    } catch (exceptionConnectionFsc) {
      CustomAlertDialog.alertDialogTitle("Something is wrong...", "No internet connection.");
    }
    
  }

  Future<void> processRegistration() async {
    
    final userData = _locator<UserDataProvider>();
    final storageData = _locator<StorageDataProvider>();
    final tempData = _locator<TempDataProvider>();

    final custUsernameInput = usernameController.text;
    final custEmailInput = emailController.text;
    final custAuth0Input = auth0Controller.text;
    final custAuth1Input = auth1Controller.text;

    if(custEmailInput.isEmpty && custUsernameInput.isEmpty && custAuth0Input.isEmpty && custAuth1Input.isEmpty) {
      CustomAlertDialog.alertDialog("Please fill all the required forms.");
      return;
    }

    if (custUsernameInput.contains(RegExp(r'[&%;?]'))) {
      CustomAlertDialog.alertDialogTitle("Sign Up Failed","Username cannot contain special characters.");
      return;
    }

    if (custAuth0Input.contains(RegExp(r'[?!]'))) {
      CustomAlertDialog.alertDialogTitle("Sign Up Failed","Password cannot contain special characters.");
      return;
    }

    if (custAuth0Input.length <= 5) {
      CustomAlertDialog.alertDialogTitle("Sign Up Failed","Password must contain more than 5 characters.");
      return;
    }

    if (custAuth1Input.length != 3) {
      CustomAlertDialog.alertDialogTitle("Sign Up Failed","PIN Number must have 3 digits.");
      return;
    }

    if (custAuth1Input.isEmpty) {
      CustomAlertDialog.alertDialogTitle("Sign Up Failed","Please add a PIN number to protect your account.");
      return;
    }

    if (!EmailValidator().validateEmail(custEmailInput)) {
      CustomAlertDialog.alertDialogTitle("Sign Up Failed","Email address is not valid.");
      return;
    }

    if (custUsernameInput.isEmpty) {
      CustomAlertDialog.alertDialogTitle("Sign Up Failed","Please enter a username.");
      return;
    }

    if (custAuth0Input.isEmpty) {
      CustomAlertDialog.alertDialog("Please enter a password.");
      return;
    }

    if (custEmailInput.isEmpty) {
      CustomAlertDialog.alertDialog("Please enter your email.");
      return;
    }

    storageData.fileNamesList.clear();
    storageData.fileNamesFilteredList.clear();
    storageData.imageBytesFilteredList.clear();
    storageData.imageBytesList.clear();
    
    userData.setUsername(custUsernameInput);
    userData.setEmail(custEmailInput);
    userData.setAccountType("Basic");
    
    tempData.setOrigin(OriginFile.home);
    
    final singleTextLoading = SingleTextLoading();

    singleTextLoading.startLoading(
      title: "Creating account...", context: context);

    await insertUserRegistrationInformation(
      username: custUsernameInput, 
      email: custEmailInput, 
      auth0: custAuth0Input, 
      auth1: custAuth1Input
    );

  }

  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        )
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(  
        padding: EdgeInsets.symmetric(
          horizontal: mediaQuery.size.width * 0.05,
          vertical: mediaQuery.size.height * 0.05,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mediaQuery.size.width * 0.02,
                vertical: mediaQuery.size.height * 0.02,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  HeaderText(title: "Sign Up", subTitle: "Create an account for Flowstorage"),

                ],
              ),
            ),

            const SizedBox(height: 15),

            MainTextField(
              hintText: "Enter a username", 
              maxLength: 32,
              controller: usernameController
            ),

            const SizedBox(height: 12),

            MainTextField(
              hintText: "Enter your email address", 
              controller: emailController
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                SizedBox(
                  width: mediaQuery.size.width*0.68,
                  child: ValueListenableBuilder(
                    valueListenable: visiblePasswordNotifier,
                    builder: (context, value, child) {
                      return TextFormField(
                        style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                        enabled: true,
                        controller: auth0Controller,
                        obscureText: !value,
                        decoration: GlobalsStyle.setupTextFieldDecoration(
                          "Enter a password",
                          customSuffix: IconButton(
                            icon: Icon(
                              value ? Icons.visibility : Icons.visibility_off,
                              color: const Color.fromARGB(255, 141, 141, 141),
                            ), 
                            onPressed: () { 
                              visiblePasswordNotifier.value = !visiblePasswordNotifier.value;
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
                const SizedBox(width: 6),

                SizedBox(
                  width: mediaQuery.size.width*0.2,
                  child: TextFormField(
                    style: const TextStyle(color: Color.fromARGB(255, 214, 213, 213)),
                    enabled: true,
                    controller: auth1Controller,
                    obscureText: true,
                    maxLength: 3,
                    keyboardType: TextInputType.number,
                    decoration: GlobalsStyle.setupTextFieldDecoration(
                      "PIN",
                      customCounterStyle: const TextStyle(color: Color.fromARGB(255,199,199,199)),
                    ),
                  ),
                ),

              ],
            ),
          
          const SizedBox(height: 25),

          MainButton(
            text: "Sign Up",
            onPressed: processRegistration,
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 35,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?  ',
                    style: TextStyle(
                      color: Color.fromARGB(255, 233, 232, 232),
                    ),
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColor.darkBlack,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        NavigatePage.goToPageLogin(context);
                      },
                      child: const Text("Sign In",
                        style: TextStyle(
                          color: ThemeColor.darkPurple,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),      
    );
  }
}
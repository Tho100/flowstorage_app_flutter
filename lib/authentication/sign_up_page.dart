import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/helper/validate_email.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';
import 'package:flowstorage_fsc/widgets/text_field/auth_text_field.dart';
import 'package:flowstorage_fsc/widgets/text_field/main_text_field.dart';
import 'package:flutter/material.dart';

import 'package:flowstorage_fsc/encryption/hash_model.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/data_classes/sign_up_process.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SignUpPage extends StatefulWidget {

  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();

}

class SignUpPageState extends State<SignUpPage> {

  final dateNow = DateFormat('yyyy/MM/dd').format(DateTime.now());

  final visiblePasswordNotifier = ValueNotifier<bool>(false);

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final auth0Controller = TextEditingController();
  final auth1Controller = TextEditingController(); 

  final _locator = GetIt.instance;

  Future<void> insertUserRegistrationInformation({
    required String username,
    required String email,
    required String auth0,
    required String auth1
  }) async {

    try {

      final valueCase0 = AuthModel().computeAuth(auth0);
      final valueCase1 = AuthModel().computeAuth(auth1);

      await SignUpUser().insertParams(
        userName: username,
        auth0: valueCase0,
        email: email,
        auth1: valueCase1,
        createdDate: dateNow,
        context: context
      );

    } catch (err) {
      CustomAlertDialog.alertDialogTitle(
        "Something is wrong...", "No internet connection.");

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
  void dispose() {
    usernameController.clear();
    auth0Controller.clear();
    emailController.clear();
    auth1Controller.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      resizeToAvoidBottomInset: false,
      body: Padding(  
        padding: EdgeInsets.symmetric(
          horizontal: mediaQuery.size.width * 0.05,
          vertical: mediaQuery.size.height * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: mediaQuery.size.width * 0.02,
                vertical: mediaQuery.size.height * 0.02,
              ),
              child: const HeaderText(
                title: "Sign Up", 
                subTitle: "Create an account for Flowstorage"
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

                AuthTextField(mediaQuery).passwordTextField(
                  controller: auth0Controller, 
                  visibility: visiblePasswordNotifier
                ),

                const SizedBox(width: 6),

                AuthTextField(mediaQuery).pinTextField(
                  controller: auth1Controller
                ),

              ],
            ),
          
            const SizedBox(height: 25),

            MainButton(
              text: "Sign Up",
              onPressed: processRegistration,
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 35,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Text(
                      'Already have an account?',
                      style: GoogleFonts.inter(
                        color: ThemeColor.secondaryWhite,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColor.darkBlack,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => NavigatePage.goToPageLogin(context),
                      child: Text(
                        "Sign In",
                        style: GoogleFonts.inter(
                          color: ThemeColor.darkPurple,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
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
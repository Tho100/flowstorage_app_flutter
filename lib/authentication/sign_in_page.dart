import 'package:flowstorage_fsc/helper/validate_email.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/user_settings/password_recovery_page.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/header_text.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';
import 'package:flowstorage_fsc/widgets/main_text_field.dart';
import 'package:flowstorage_fsc/data_classes/login_process.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatefulWidget {

  const SignInPage({Key? key}) : super(key: key);

  @override
  SignInPageState createState() => SignInPageState(); 

}

class SignInPageState extends State<SignInPage> {

  final userData = GetIt.instance<UserDataProvider>();

  final isCheckedNotifier = ValueNotifier<bool>(true); 
  final visiblePasswordNotifier = ValueNotifier<bool>(false); 

  final emailController = TextEditingController();
  final auth0Controller = TextEditingController();
  final auth1Controller = TextEditingController();

  Future<void> verifyUserSignInInformation({
    required String email,
    required String auth0,
    required String auth1
  }) async {

    await SignInUser().logParams(email, auth0, auth1, isCheckedNotifier.value, context);

  }
  
  Future<void> processSignIn() async {

    final custAuth0Input = auth0Controller.text.trim();
    final custAuth1Input = auth1Controller.text.trim();
    final custEmailInput = emailController.text.trim();

    if (!EmailValidator().validateEmail(custEmailInput)) {
      CustomAlertDialog.alertDialogTitle("Sign In Failed","Email address is not valid.");
      return;
    }

    if (custAuth1Input.isEmpty) {
      CustomAlertDialog.alertDialogTitle("Sign In Failed","Please enter your PIN key.");
      return;
    }

    if (custEmailInput.isEmpty) {
      CustomAlertDialog.alertDialogTitle("Sign In Failed","Please enter your email address.");
      return;
    }

    if (custAuth0Input.isEmpty) {
      CustomAlertDialog.alertDialogTitle("Sign In Failed","Please enter your password.");              
      return;
    }

    await verifyUserSignInInformation(
      email: custEmailInput, 
      auth0: custAuth0Input, 
      auth1: custAuth1Input
    );
    
  }

  @override
  void dispose() {
    emailController.dispose();
    auth0Controller.dispose();
    auth1Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        context: context,
        title: ""
      ).buildAppBar(),
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeaderText(title: "Sign In", subTitle: "Sign in to your Flowstorage account"),
                ],
              ),
            ),

          const SizedBox(height: 15),

          MainTextField(
            hintText: "Enter your email address", 
            controller: emailController,
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
                      style: const TextStyle(
                        color: ThemeColor.secondaryWhite,
                        fontWeight: FontWeight.w500,
                      ),
                      enabled: true,
                      controller: auth0Controller,
                      obscureText: !value,
                      decoration: GlobalsStyle.setupTextFieldDecoration(
                        "Enter your password", 
                        customSuffix: IconButton(
                          icon: Icon(value ? Icons.visibility : Icons.visibility_off,
                            color: ThemeColor.thirdWhite,
                          ), 
                          onPressed: () => visiblePasswordNotifier.value = !visiblePasswordNotifier.value,
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
                  style: const TextStyle(
                    color: ThemeColor.secondaryWhite,
                    fontWeight: FontWeight.w500,
                  ),
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

          const SizedBox(height: 15),

          CheckboxTheme(
            data: CheckboxThemeData(
              fillColor: MaterialStateColor.resolveWith(
                  (states) => ThemeColor.darkGrey,
                ),
              checkColor: MaterialStateColor.resolveWith(
                  (states) => ThemeColor.secondaryWhite,
                ),
              overlayColor: MaterialStateColor.resolveWith(
                  (states) => ThemeColor.secondaryWhite.withOpacity(0.1),
                ),
              side: const BorderSide(
                  color: ThemeColor.lightGrey,
                  width: 2.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              child: Row(
                children: [
                  ValueListenableBuilder(
                    valueListenable: isCheckedNotifier,
                    builder: (context, value, child) {
                      return Checkbox(
                        value: value,
                        onChanged: (checkedValue) {
                          isCheckedNotifier.value = checkedValue ?? true;
                        },
                      );
                    },
                  ),
                  const Text(
                    "Remember Me",
                    style: TextStyle(
                      color: Color.fromARGB(225, 225, 225, 225),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            MainButton(
              text: "Sign In", 
              onPressed: processSignIn
            ),
        
            const Spacer(),

            Center(
              child: Column(
                children: [
                  Text('Forgot your password?',
                    style: GoogleFonts.poppins(
                      color: ThemeColor.secondaryWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => PasswordRecoveryPage(username: userData.username)));
                    },
                    child: const Text('Reset with Recovery Key',  
                      style: TextStyle(
                        color: ThemeColor.darkPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 17
                      ),
                    ),
                  ),

                ],
              )
            ),
          ],
        ),
      ),      
    );
  }

}
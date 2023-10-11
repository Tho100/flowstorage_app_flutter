import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/add_password_sharing.dart';
import 'package:flowstorage_fsc/sharing_query/sharing_options.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/main_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class ConfigureSharingPasswordPage extends StatefulWidget {
  const ConfigureSharingPasswordPage({super.key});

  @override
  State<ConfigureSharingPasswordPage> createState() => ConfigureSharingPasswordState();
}

class ConfigureSharingPasswordState extends State<ConfigureSharingPasswordPage> {

  final userData = GetIt.instance<UserDataProvider>();
  final addPasswordController = TextEditingController();

  bool isPasswordEnabled = false;

  void togglePasscode(String disabled) async {

    disabled == "0"
    ? await UpdatePasswordSharing().enable(username: userData.username)
    : await UpdatePasswordSharing().disable(username: userData.username);

  }

  Future buildAddPasswordDialog() {
    return InteractDialog().buildDialog(
      context: context, 
      childrenWidgets: <Widget>[
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0, left: 18.0, right: 18.0, top: 16.0),
              child: Text(
                "Password for File Sharing",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 17,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const Divider(color: ThemeColor.lightGrey),
        
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 6.0, top: 8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(width: 1.0, color: ThemeColor.darkBlack),
            ),
            child: TextFormField(
              style: const TextStyle(color: ThemeColor.justWhite),
              enabled: true,
              controller: addPasswordController,
              decoration: GlobalsStyle.setupTextFieldDecoration("Enter password")
            ),
          ),
        ),

        const SizedBox(height: 5),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            const SizedBox(width: 5),

            MainDialogButton(
              text: "Close", 
              onPressed: () {
                addPasswordController.clear();
                Navigator.pop(context);
              }, 
              isButtonClose: true
            ),
              
            const SizedBox(width: 10),

            MainDialogButton(
              text: "Confirm",
              onPressed: () async {

                try {

                  if(addPasswordController.text.isEmpty) {
                    return;
                  }

                  final getAddPassword = UpdatePasswordSharing();
                  await getAddPassword.update(
                    username: userData.username, 
                    newAuth: addPasswordController.text
                  );

                  CustomAlertDialog.alertDialogTitle("Added password for File Sharing", "Users are required to enter the password before they can share a file with you.");

                } catch (err, st) {
                  Logger().e("Exception from _buildAddPassword {settings_page}", err, st);
                  CustomAlertDialog.alertDialogTitle("An error occurred", "Faild to add/update pasword for File Sharing. Please try again later.");
                }

              },
              isButtonClose: false,
            ),

            const SizedBox(width: 18),
          ],
        ),
        const SizedBox(height: 12),
      ]
    );
  }

  Widget buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 2.0), 
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Enable sharing password",
                        style: GlobalsStyle.settingsLeftTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      Switch(
                        inactiveThumbColor: ThemeColor.darkPurple,
                        activeColor: ThemeColor.darkPurple,
                        value: isPasswordEnabled,
                        onChanged: (value) async {
                          setState(() {
                            isPasswordEnabled = value;
                          });

                          final passwordIsDisabled = await SharingOptions.retrievePasswordStatus(userData.username);
                          final retrievedPassword = await SharingOptions.retrievePassword(userData.username);

                          if (passwordIsDisabled == "1" && retrievedPassword == "DEF") {
                            isPasswordEnabled = false;
                            if (!mounted) return;
                            buildAddPasswordDialog();

                          } else {
                            final isEnabled = isPasswordEnabled ? "0" : "1";
                            togglePasscode(isEnabled);

                          }

                        },
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),

          Visibility(
            visible: isPasswordEnabled,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        buildAddPasswordDialog();
                      },
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            "Edit password",
                            style: GlobalsStyle.settingsLeftTextStyle,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Edit sharing password",
                            style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: ThemeColor.thirdWhite),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPasswordStatus() async {

    final passwordIsDisabled = await SharingOptions.retrievePasswordStatus(userData.username);

    if(passwordIsDisabled == "1") {
      setState(() {
        isPasswordEnabled = false;
      });

    } else {
      setState(() {
        isPasswordEnabled = true;
      });

    }

  }

  @override
  void initState() {
    super.initState();
    _loadPasswordStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        title: const Text("Configure sharing password",
          style: GlobalsStyle.appBarTextStyle,
        ),
      ),
      body: buildBody(),
    );
  }
}
import 'package:flowstorage_fsc/interact_dialog/sharing_dialog/add_password_dialog.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/add_password_sharing.dart';
import 'package:flowstorage_fsc/sharing_query/sharing_options.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ConfigureSharingPasswordPage extends StatefulWidget {
  const ConfigureSharingPasswordPage({super.key});

  @override
  State<ConfigureSharingPasswordPage> createState() => ConfigureSharingPasswordState();
}

class ConfigureSharingPasswordState extends State<ConfigureSharingPasswordPage> {

  final userData = GetIt.instance<UserDataProvider>();

  bool isPasswordEnabled = false;

  void togglePasscode(String disabled) async {

    disabled == "0"
    ? await UpdatePasswordSharing().enable(username: userData.username)
    : await UpdatePasswordSharing().disable(username: userData.username);
    
    userData.setSharingPasswordStatus(disabled);

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
                      Transform.scale(
                        scale: 1.1,
                        child: Switch(
                          inactiveThumbColor: ThemeColor.darkPurple,
                          activeColor: ThemeColor.darkPurple,
                          inactiveTrackColor: ThemeColor.darkGrey,
                          value: isPasswordEnabled,
                          onChanged: (value) async {
                            setState(() {
                              isPasswordEnabled = value;
                            });
                      
                            final retrievedPassword = await SharingOptions.retrievePassword(userData.username);
                      
                            if (userData.sharingPasswordDisabled == "1" && retrievedPassword == "DEF") {
                              if(!mounted) return;
                              AddSharingPassword().buildAddPasswordDialog(context);
                      
                            } else {
                              final isEnabled = isPasswordEnabled ? "0" : "1";
                              togglePasscode(isEnabled);
                      
                            }
                      
                          },
                        ),
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
                        if(!mounted) return;
                        AddSharingPassword().buildAddPasswordDialog(context);
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

    if(userData.sharingPasswordDisabled.isEmpty) {
      final passwordIsDisabled = await SharingOptions.retrievePasswordStatus(userData.username);
      userData.setSharingPasswordStatus(passwordIsDisabled);
    } 

    setState(() {
      isPasswordEnabled = userData.sharingPasswordDisabled == "0";
    });

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
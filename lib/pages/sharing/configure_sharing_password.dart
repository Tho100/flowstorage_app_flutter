import 'package:flowstorage_fsc/interact_dialog/sharing_dialog/add_password_dialog.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/add_password_sharing.dart';
import 'package:flowstorage_fsc/sharing_query/sharing_options.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/default_switch.dart';
import 'package:flowstorage_fsc/widgets/settings_button.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0), 
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Enable sharing password",
                style: GlobalsStyle.settingsLeftTextStyle,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              DefaultSwitch(
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
                }
              ),

            ],
          ),
        ),
         

        const SizedBox(height: 8),

        Visibility(
          visible: isPasswordEnabled,
          child: SettingsButton(
            topText: "Edit password", 
            bottomText: "Update your sharing password", 
            onPressed: () {
              if(!mounted) return;
              AddSharingPassword().buildAddPasswordDialog(context);
            }
          ),
        ),
      ],
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
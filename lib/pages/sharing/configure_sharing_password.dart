import 'package:flowstorage_fsc/interact_dialog/sharing_dialog/add_password_dialog.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/add_password_sharing.dart';
import 'package:flowstorage_fsc/sharing_query/sharing_options.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/default_switch.dart';
import 'package:flowstorage_fsc/widgets/buttons/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ConfigureSharingPasswordPage extends StatefulWidget {

  const ConfigureSharingPasswordPage({super.key});

  @override
  State<ConfigureSharingPasswordPage> createState() => ConfigureSharingPasswordState();
  
}

class ConfigureSharingPasswordState extends State<ConfigureSharingPasswordPage> {

  final userData = GetIt.instance<UserDataProvider>();

  final isPasswordEnabledNotifier = ValueNotifier<bool>(false);

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
            children: [

              Text(
                "Enable sharing password",
                style: GlobalsStyle.settingsLeftTextStyle,
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              ValueListenableBuilder(
                valueListenable: isPasswordEnabledNotifier,
                builder: (context, value, child) {
                  return DefaultSwitch(
                    value: value, 
                    onChanged: (value) async {
                      isPasswordEnabledNotifier.value = value;
                            
                      final retrievedPassword = await SharingOptions.retrievePassword(userData.username);
                            
                      if (userData.sharingPasswordDisabled == "1" && retrievedPassword == "DEF") {
                        AddSharingPassword().buildAddPasswordDialog();
                            
                      } else {
                        final isEnabled = isPasswordEnabledNotifier.value 
                          ? "0" : "1";
                        togglePasscode(isEnabled);
                            
                      }
                    }
                  );
                },
              ),

            ],
          ),
        ),
         
        const SizedBox(height: 8),

        ValueListenableBuilder(
          valueListenable: isPasswordEnabledNotifier,
          builder: (context, value, child) {
            return Visibility(
              visible: value,
              child: SettingsButton(
                topText: "Edit password", 
                bottomText: "Update your sharing password", 
                onPressed: () => AddSharingPassword().buildAddPasswordDialog(),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _loadPasswordStatus() async {

    if(userData.sharingPasswordDisabled.isEmpty) {
      final passwordIsDisabled = await SharingOptions.retrievePasswordStatus(userData.username);
      userData.setSharingPasswordStatus(passwordIsDisabled);
    } 

    isPasswordEnabledNotifier.value = userData.sharingPasswordDisabled == "0";

  }

  @override
  void initState() {
    super.initState();
    _loadPasswordStatus();
  }

  @override
  void dispose() {
    isPasswordEnabledNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context,
        title: "Configure sharing password"
      ).buildAppBar(),
      body: buildBody(),
    );
  }

}
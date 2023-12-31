import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/sharing_options.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/default_switch.dart';
import 'package:flowstorage_fsc/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsSharingPage extends StatelessWidget {

  final bool isSharingDisabled;

  SettingsSharingPage({
    required this.isSharingDisabled,
    super.key
  });

  final userData = GetIt.instance<UserDataProvider>();

  final sharingDisabledStatusNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    sharingDisabledStatusNotifier.value = isSharingDisabled;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
        title: const Text("Sharing",
          style: GlobalsStyle.appBarTextStyle,
        ),
      ),
      body: Column(
        children: [
          
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0), 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                const Text(
                  "Enable file sharing",
                  style: GlobalsStyle.settingsLeftTextStyle,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                ValueListenableBuilder(
                  valueListenable: sharingDisabledStatusNotifier,
                  builder: (context, sharingDisabled, child) {
                    return DefaultSwitch(
                      value: sharingDisabled, 
                      onChanged: (switchValue) async {
                        sharingDisabledStatusNotifier.value = !sharingDisabledStatusNotifier.value;

                        if(switchValue == false) {
                          await SharingOptions.disableSharing(userData.username);
                          userData.setSharingStatus("1");

                        } else {
                          await SharingOptions.enableSharing(userData.username);  
                          userData.setSharingStatus("0");

                        }

                      },
                    );
                  },
                ),
                
              ],
            ),
          ),

          const SizedBox(height: 8),
    
          SettingsButton(
            topText: "Configure password", 
            bottomText: "Require password for file sharing with you", 
            onPressed: () async {
              NavigatePage.goToPageCongfigureSharingPassword();
            }
          ),

        ],
      ),
    );
  }
}
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/sharing_options.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/default_switch.dart';
import 'package:flowstorage_fsc/widgets/buttons/settings_button.dart';
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
      appBar: CustomAppBar(
        context: context, 
        title: "Sharing"
      ).buildAppBar(),
      body: Column(
        children: [
          
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 18.0), 
            child: Row(
              children: [

                Text(
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

                        if(!switchValue) {
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
            onPressed: () => NavigatePage.goToPageConfigureSharingPassword(),
          ),

        ],
      ),
    );
  }
}
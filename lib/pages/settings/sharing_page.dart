import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/sharing_options.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsSharingPage extends StatelessWidget {

  final String sharingEnabledButton;

  SettingsSharingPage({
    required this.sharingEnabledButton,
    super.key
  });

  final userData = GetIt.instance<UserDataProvider>();
/*sharingEnabledButton == 'Disable' 
  ? await SharingOptions.disableSharing(custUsername) 
  : await SharingOptions.enableSharing(custUsername);

  setState(() {
    sharingEnabledButton = sharingEnabledButton == "Disable" ? "Enable" : "Disable";
  });

  final sharingStatus = sharingEnabledButton == "Enable" ? "Disabled" : "Enabled";

  const fileSharingDisabledMsg = "File sharing disabled. No one can share a file to you.";
  const fileSharingEnabledMsg = "File sharing enabled. People can share a file to you.";

  final updatedStatus = sharingEnabledButton == "Enable" ? "1" : "0";

  userData.setSharingStatus(updatedStatus);

  final conclusionSubMsg = sharingStatus == "Disabled" ? fileSharingDisabledMsg : fileSharingEnabledMsg;
  CustomAlertDialog.alertDialogTitle("Sharing $sharingStatus", conclusionSubMsg); */
  @override
  Widget build(BuildContext context) {
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

          SettingsButton(
            topText: "File sharing", 
            bottomText: sharingEnabledButton, 
            onPressed: () async {

              sharingEnabledButton == 'Disable' 
              ? await SharingOptions.disableSharing(userData.username) 
              : await SharingOptions.enableSharing(userData.username);
    
              final updatedSharingEnabledUpdate = sharingEnabledButton == "Disable" ? "Enable" : "Disable";

              final sharingStatus = updatedSharingEnabledUpdate == "Enable" ? "Disabled" : "Enabled";

              const fileSharingDisabledMsg = "File sharing disabled. No one can share a file to you.";
              const fileSharingEnabledMsg = "File sharing enabled. People can share a file to you.";

              final updatedStatus = updatedSharingEnabledUpdate == "Enable" ? "1" : "0";

              userData.setSharingStatus(updatedStatus);

              final conclusionSubMsg = sharingStatus == "Disabled" ? fileSharingDisabledMsg : fileSharingEnabledMsg;
              CustomAlertDialog.alertDialogTitle("Sharing $sharingStatus", conclusionSubMsg);
            }
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
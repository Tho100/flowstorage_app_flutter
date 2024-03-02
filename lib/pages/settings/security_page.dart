import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/buttons/settings_button.dart';
import 'package:flutter/material.dart';

class SettingsSecurityPage extends StatelessWidget {

  const SettingsSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
        title: const Text("Security",
          style: GlobalsStyle.appBarTextStyle,
        ),
      ),
      body: Column(
        children: [

          const SizedBox(height: 8),

          SettingsButton(
            topText: "Configure passcode", 
            bottomText: "Require to enter passcode before allowing to open Flowstorage", 
            onPressed: () async {
              NavigatePage.goToPageConfigurePasscode();
            }
          ),

          SettingsButton(
            topText: "Backup recovery key", 
            bottomText: "Recovery key enables password reset in case \nof forgotten passwords", 
            onPressed: () async {
              NavigatePage.goToPageBackupRecovery();
            }
            
          ),
        ],
      ),
    );
  }

}
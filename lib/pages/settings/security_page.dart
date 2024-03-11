import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/buttons/settings_button.dart';
import 'package:flutter/material.dart';

class SettingsSecurityPage extends StatelessWidget {

  const SettingsSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context, 
        title: "Security"
      ).buildAppBar(),
      body: Column(
        children: [

          const SizedBox(height: 8),

          SettingsButton(
            topText: "Configure passcode", 
            bottomText: "Require to enter passcode before allowing to open Flowstorage", 
            onPressed: () => NavigatePage.goToPageConfigurePasscode(),
          ),

          SettingsButton(
            topText: "Backup recovery key", 
            bottomText: "Recovery key enables password reset in case \nof forgotten passwords", 
            onPressed: () => NavigatePage.goToPageBackupRecovery(),
          ),
          
        ],
      ),
    );
  }

}
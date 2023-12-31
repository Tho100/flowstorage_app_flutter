import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/interact_dialog/delete_account_dialog/verify_account_deletion_dialog.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flowstorage_fsc/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SettingsAccountPage extends StatelessWidget {

  SettingsAccountPage({super.key});

  static final userData = GetIt.instance<UserDataProvider>();
  static final accountType = userData.accountType;

  final email = userData.email;
  final uploadLimit = AccountPlan.mapFilesUpload[accountType];

  Widget _buildRow(String leftText,String rightText) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0, top: 8, bottom: 8),
          child: Text(leftText,
            style: GlobalsStyle.settingsLeftTextStyle
          ),
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.only(right: 18.0, top: 8, bottom: 8),
          child: Text(rightText,
            style: const TextStyle(
              fontSize: 17,
              color: ThemeColor.thirdWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
        title: const Text("Account",
          style: GlobalsStyle.appBarTextStyle,
        ),
      ),
      body: Column(
        children: [
          
          const SizedBox(height: 8),

          _buildRow("Email", email),
          _buildRow("Account Type", accountType),
          _buildRow("Upload Limit", uploadLimit.toString()),

          const SizedBox(height: 12),

          SettingsButton(
            topText: "Change my password", 
            bottomText: "Update your account password", 
            onPressed: () {
              NavigatePage.goToPageChangePass(context);
            }
          ),

          SettingsButton(
            topText: "Remove Account", 
            bottomText: "Delete all your account data and informations", 
            onPressed: () {
              VerifyAccountDeletionDialog()
                .buildVerifyAccountDeletionDialog();
            }
          ),

        ],
      ),
    );
  }
}
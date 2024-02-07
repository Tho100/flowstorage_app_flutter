import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flowstorage_fsc/widgets/buttons/settings_button.dart';
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
          _buildRow("Account plan", accountType),
          _buildRow("Upload limit", uploadLimit.toString()),

          const SizedBox(height: 5),

          const Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Divider(color: ThemeColor.lightGrey),
          ),

          const SizedBox(height: 5),

          SettingsButton(
            topText: "Change my password", 
            bottomText: "Update your account password", 
            onPressed: () {
              NavigatePage.goToPageChangePass(context);
            }
          ),

          SettingsButton(
            topText: "My accounts", 
            bottomText: "See all your existing accounts", 
            onPressed: () {
              NavigatePage.goToPageMyAccounts();
            }
          ),

          Visibility(
            visible: accountType != "Basic",
            child: Column(
              children: [                                                
                SettingsButton(
                  topText: "My plan", 
                  bottomText: "See your subscription plan details", 
                  onPressed: () async {
                    NavigatePage.goToPageMyPlan();
                  }
                ),
              ],
            )
          ),

          SettingsButton(
            topText: "Remove account", 
            bottomText: "Delete all your account data and informations", 
            onPressed: () {
              NavigatePage.goToPageDeleteAccount();
            }
          ),

        ],
      ),
    );
  }
}
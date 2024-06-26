import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/buttons/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

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
            style: GoogleFonts.inter(
              fontSize: 16,
              color: ThemeColor.thirdWhite,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context, 
        title: "Account"
      ).buildAppBar(),
      body: Column(
        children: [
          
          const SizedBox(height: 8),

          _buildRow("Email", email),
          _buildRow("Account plan", accountType),
          _buildRow("Upload limit", uploadLimit.toString()),

          const SizedBox(height: 5),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: ThemeColor.lightGrey),
          ),

          const SizedBox(height: 5),

          SettingsButton(
            topText: "Change my password", 
            bottomText: "Update your account password", 
            onPressed: () => NavigatePage.goToPageChangePass(),
          ),

          SettingsButton(
            topText: "My accounts", 
            bottomText: "See all your existing accounts", 
            onPressed: () => NavigatePage.goToPageMyAccounts(),
          ),

          SettingsButton(
            topText: "My plan", 
            bottomText: "See your plan details", 
            onPressed: () => NavigatePage.goToPageMyPlan(),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: ThemeColor.lightGrey),
          ),

          SettingsButton(
            topText: "Remove account", 
            bottomText: "Delete all your account data and information", 
            onPressed: () => NavigatePage.goToPageDeleteAccount(),
          ),

        ],
      ),
    );
  }
  
}
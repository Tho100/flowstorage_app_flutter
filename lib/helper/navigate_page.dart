import 'package:flowstorage_fsc/pages/share_file_page.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flowstorage_fsc/user_settings/add_passcode_page.dart';
import 'package:flowstorage_fsc/user_settings/backup_recovery_page.dart';
import 'package:flowstorage_fsc/pages/my_plan_page.dart';
import 'package:flowstorage_fsc/user_settings/update_password_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../pages/main_page.dart';
import '../pages/passcode_page.dart';
import '../authentication/sign_in_page.dart';
import '../authentication/sign_up_page.dart';
import '../main.dart';
import '../pages/create_text.dart';
import '../pages/statistics_page.dart';
import '../sharing_query/sharing_options.dart';
import '../upgrades/upgrade_page.dart';
import '../pages/settings_page.dart';

class NavigatePage {

  static void goToPageSharing(BuildContext context, String fileName) {
     Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => ShareFilePage(fileName: fileName)),
    );
  }

  static void replacePageMain(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }
  
  static void permanentPageHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => const MainPage()), 
      (route) => false);
  }

  static void replacePageMainboard(BuildContext context) {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const Mainboard())
    );   
  }

  static void permanentPageMainboard(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Mainboard()),
      (route) => false,
    );
  }

  static void goToPageLogin(BuildContext context) {
     Navigator.push(context, 
      MaterialPageRoute(builder: (context) => const CakeSignInPage()),
    );
  }

  static void goToPageRegister(BuildContext context) {
    Navigator.push(context, 
      MaterialPageRoute(builder: (context) => const CakeSignUpPage()),
    );
  }
  
  static void goToPageStatistics(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (_) => const StatisticsPage(),
      )
    );
  }

  static void goToPageUpgrade(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UpradePage())
    );
  }

  static void goToPageCreateText(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateText())
    );
  }

  static void goToPageSettings(BuildContext context) async {

    final userData = GetIt.instance<UserDataProvider>();

    final username = userData.username;
    final email = userData.email;
    final accountType = userData.accountType;

    try {

      if(userData.sharingStatus.isEmpty) {
        final status = await SharingOptions.retrieveDisabled(userData.username);
        userData.setSharingStatus(status);
      } 

      _openSettingsPage(
        email: email,
        username: username,
        accountType: accountType,
        sharingDisabledStatus: userData.sharingStatus,
      );

    } catch (err, st) {

      SnakeAlert.errorSnake("No internet connection.");
      Logger().e("Exception on goToPageSettings (NavigatePage)", err, st);
      
      await Future.delayed(const Duration(milliseconds: 990));

      _openSettingsPage(
        sharingDisabledStatus: "0",
        email: email,
        username: username,
        accountType: accountType,
      );

    }
  }

  static void _openSettingsPage({
    required String email, 
    required String username,
    required String accountType,
    required String sharingDisabledStatus
  }) {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => 
          CakeSettingsPage(
          accType: accountType,
          custEmail: email,
          custUsername: username,
          uploadLimit: AccountPlan.mapFilesUpload[accountType]!,
          sharingEnabledButton: sharingDisabledStatus,
        ),
      ),
    );
  }

  static void goToPageBackupRecovery(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BackupRecovery())
    );
  }

  static void goToPageMyPlan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyPlanPage())
    );
  }

  static void goToAddPasscodePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPasscodePage())
    );
  }

  static void goToPageChangePass(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePassword())
    );
  }

  static void goToPagePasscode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PasscodePage())
    );
  }

}
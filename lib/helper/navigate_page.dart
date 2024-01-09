import 'package:flowstorage_fsc/pages/acitivity_page.dart';
import 'package:flowstorage_fsc/pages/comment_page.dart';
import 'package:flowstorage_fsc/pages/file_details.dart';
import 'package:flowstorage_fsc/pages/move_file_page.dart';
import 'package:flowstorage_fsc/pages/passcode/configure_passcode_page.dart';
import 'package:flowstorage_fsc/pages/settings/account_page.dart';
import 'package:flowstorage_fsc/pages/settings/app_page.dart';
import 'package:flowstorage_fsc/pages/settings/security_page.dart';
import 'package:flowstorage_fsc/pages/settings/sharing_page.dart';
import 'package:flowstorage_fsc/pages/sharing/configure_sharing_password.dart';
import 'package:flowstorage_fsc/pages/sharing/share_file_page.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flowstorage_fsc/pages/passcode/add_passcode_page.dart';
import 'package:flowstorage_fsc/user_settings/backup_recovery_page.dart';
import 'package:flowstorage_fsc/pages/my_plan_page.dart';
import 'package:flowstorage_fsc/user_settings/update_password_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../pages/main_page.dart';
import '../pages/passcode/passcode_page.dart';
import '../authentication/sign_in_page.dart';
import '../authentication/sign_up_page.dart';
import '../main.dart';
import '../pages/create_text.dart';
import '../pages/statistics_page.dart';
import '../sharing_query/sharing_options.dart';
import '../upgrades/upgrade_page.dart';
import '../pages/settings_page.dart';

class NavigatePage {

  static void goToPageFileDetails(String fileName) {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => FileDetailsPage(fileName: fileName,))
    );
  }

  static void goToPageSharing(String fileName) {
     Navigator.push(
      navigatorKey.currentContext!, 
      MaterialPageRoute(builder: (context) => ShareFilePage(fileName: fileName)),
    );
  }

  static void goToPageMoveFile(List<String> fileNames, List<String> fileBase64) {
     Navigator.push(
      navigatorKey.currentContext!, 
      MaterialPageRoute(builder: (context) => MoveFilePage(
        fileNames: fileNames, fileBase64Data: fileBase64)
      ),
    );
  }

  static void goToPageActivity(VoidCallback publicStorageFunction) {
     Navigator.push(
      navigatorKey.currentContext!, 
      MaterialPageRoute(builder: (context) => ActivityPage(publicStorageFunction: publicStorageFunction)
      ),
    );
  }

  static void goToPageCongfigurePasscode() {
    Navigator.push(
      navigatorKey.currentContext!, 
      MaterialPageRoute(builder: (context) => const ConfigurePasscodePage()),
    );
  }

  static void goToPageCongfigureSharingPassword() {
    Navigator.push(
      navigatorKey.currentContext!, 
      MaterialPageRoute(builder: (context) => const ConfigureSharingPasswordPage()),
    );
  }

  static void goToPageFileComment(String fileName) {
    Navigator.push(
      navigatorKey.currentContext!, 
      MaterialPageRoute(builder: (context) => CommentPage(fileName: fileName)),
    );
  }

  static void replacePageMain(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }
  
  static void permanentPageMain(BuildContext context) {
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
  
  static void goToPageStatistics() {
    Navigator.push(
      navigatorKey.currentContext!, 
      MaterialPageRoute(
        builder: (_) => const StatisticsPage(),
      )
    );
  }

  static void goToPageUpgrade() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => const UpradePage())
    );
  }

  static void goToPageCreateText() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => const CreateText())
    );
  }

  static void goToPageSettings() async {

    final userData = GetIt.instance<UserDataProvider>();

    final username = userData.username;
    final email = userData.email;
    final accountType = userData.accountType;

    try {

      _openSettingsPage(
        email: email,
        username: username,
        accountType: accountType,
      );

    } catch (err, st) {

      SnakeAlert.errorSnake("No internet connection.");
      Logger().e("Exception on goToPageSettings (NavigatePage)", err, st);
      
      await Future.delayed(const Duration(milliseconds: 990));

      _openSettingsPage(
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
        ),
      ),
    );
  }

  static void goToPageBackupRecovery() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => const BackupRecovery())
    );
  }

  static void goToPageMyPlan() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => const MyPlanPage())
    );
  }

  static void goToAddPasscodePage() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => const AddPasscodePage())
    );
  }

  static void goToPageChangePass(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UpdatePasswordPage())
    );
  }

  static void goToPagePasscode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PasscodePage())
    );
  }

  static void goToSecurityPage() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => const SettingsSecurityPage())
    );
  }

  static void goToSettingsSharingPage() async{

    final userData = GetIt.instance<UserDataProvider>();

    if(userData.sharingStatus.isEmpty) {
      final status = await SharingOptions.retrieveDisabled(userData.username);
      userData.setSharingStatus(status);
    } 

    final isSharingDisabled = userData.sharingStatus == "0" 
    ? true
    : false;

    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => SettingsSharingPage(isSharingDisabled: isSharingDisabled))
    );

  }

  static void goToPageSettingsAccount() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => SettingsAccountPage())
    );
  }

  static void goToPageSettingsAppSettings() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => SettingsAppSettings())
    );
  }

}
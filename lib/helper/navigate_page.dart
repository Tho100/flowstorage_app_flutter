import 'package:flowstorage_fsc/pages/activity_page.dart';
import 'package:flowstorage_fsc/pages/comment_page.dart';
import 'package:flowstorage_fsc/pages/file_details.dart';
import 'package:flowstorage_fsc/pages/home_page.dart';
import 'package:flowstorage_fsc/pages/mini_game.dart';
import 'package:flowstorage_fsc/pages/move_file_page.dart';
import 'package:flowstorage_fsc/pages/passcode/configure_passcode_page.dart';
import 'package:flowstorage_fsc/pages/scheduled_upgrade_page.dart';
import 'package:flowstorage_fsc/pages/settings/account_page.dart';
import 'package:flowstorage_fsc/pages/settings/app_page.dart';
import 'package:flowstorage_fsc/pages/settings/security_page.dart';
import 'package:flowstorage_fsc/pages/settings/sharing_page.dart';
import 'package:flowstorage_fsc/pages/sharing/configure_sharing_password.dart';
import 'package:flowstorage_fsc/pages/sharing/share_file_page.dart';
import 'package:flowstorage_fsc/pages/user_accounts_page.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/pages/passcode/add_passcode_page.dart';
import 'package:flowstorage_fsc/user_settings/backup_recovery_page.dart';
import 'package:flowstorage_fsc/pages/my_plan_page.dart';
import 'package:flowstorage_fsc/user_settings/delete_account_page.dart';
import 'package:flowstorage_fsc/user_settings/update_password_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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

  static void goToPageConfigurePasscode() {
    Navigator.push(
      navigatorKey.currentContext!, 
      MaterialPageRoute(builder: (context) => const ConfigurePasscodePage()),
    );
  }

  static void goToPageConfigureSharingPassword() {
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
      (route) => false
    );
  }

  static void permanentPageHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
      (route) => false,
    );
  }

  static void goToPageLogin(BuildContext context) {
     Navigator.push(context, 
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  static void goToPageRegister(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const SignUpPage()),
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
      MaterialPageRoute(builder: (context) => const UpgradePage())
    );
  }

  static void goToPageCreateText() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => const CreateText())
    );
  }

  static void goToPageSettings() async {
    Navigator.push(
      navigatorKey.currentContext!, 
      MaterialPageRoute(builder: (context) => const SettingsPage())
    );
  }

  static void goToPageBackupRecovery() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => BackupRecoveryPage())
    );
  }

  static void goToPageDeleteAccount() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => DeleteAccountPage())
    );
  }

  static void goToPageMyPlan() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => const MyPlanPage())
    );
  }

  static void goToAddPasscodePage(bool isFromConfigurePasscode) {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => AddPasscodePage(isFromConfigurePasscode: isFromConfigurePasscode))
    );
  }

  static void goToPageChangePass() {
    Navigator.push(
      navigatorKey.currentContext!,
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
      MaterialPageRoute(builder: (context) => const SettingsAppSettings())
    );
  }

  static void goToPageMyAccounts() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => const UserAccountsPage())
    );
  }

  static void goToPagePongGame() {
    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(builder: (context) => const PongGame())
    );
  }

  static void goToPageScheduledUpgrade() {
    Navigator.push(
      navigatorKey.currentContext!,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ScheduledUpgradePage(),
        transitionDuration: const Duration(microseconds: 0), 
      ),
    );
  }

}
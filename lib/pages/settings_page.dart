import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_classes/data_caller.dart';
import 'package:flowstorage_fsc/interact_dialog/signout_dialog.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/sharing_options.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CakeSettingsPage extends StatefulWidget {

  final String custUsername;
  final String custEmail;
  final String accType;
  final int uploadLimit;
  final String sharingEnabledButton;

  const CakeSettingsPage({
    Key? key, 
    required this.custUsername, 
    required this.custEmail, 
    required this.accType,
    required this.uploadLimit,
    required this.sharingEnabledButton,
  }) : super(key: key);

  @override
  CakeSettingsPageState createState() => CakeSettingsPageState();
}

class CakeSettingsPageState extends State<CakeSettingsPage> {

  late String custUsername;
  late String custEmail;
  late String accountType;
  late int uploadLimit;
  late String sharingEnabledButton;

  final dataCaller = DataCaller();

  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();
  
  void _clearUserStorageData() {
    storageData.fileNamesList.clear();
    storageData.fileNamesFilteredList.clear();
    storageData.fileDateList.clear();
    storageData.imageBytesList.clear();
    storageData.imageBytesFilteredList.clear();
    tempStorageData.folderNameList.clear();
  }

  void _clearAppCache() async {
    final cacheDir = await getTemporaryDirectory();
    await DefaultCacheManager().emptyCache();
    cacheDir.delete(recursive: true);
  }

  Future<void> _deleteAutoLoginAndOfflineFiles() async {

    final getDirApplication = await getApplicationDocumentsDirectory();

    final setupPath = '${getDirApplication.path}/$localAccountInformation';
    final setupInfosDir = Directory(setupPath);

    if (setupInfosDir.existsSync()) {
      setupInfosDir.deleteSync(recursive: true);
    }

    final offlineDirs = Directory('${getDirApplication.path}/offline_files');
    
    if(offlineDirs.existsSync()) {
      offlineDirs.delete(recursive: true);
    }

    const storage = FlutterSecureStorage();
    
    if(await storage.containsKey(key: "key0015")) {
      await storage.delete(key: "key0015");
      await storage.delete(key: "isEnabled");
    }

  }

  Widget _buildRow(String leftText,String rightText) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 8, bottom: 8),
          child: Text(leftText,
            style: GlobalsStyle.settingsLeftTextStyle
          ),
        ),

        const Spacer(),

        Padding(
          padding: const EdgeInsets.only(right: 15.0, top: 8, bottom: 8),
          child: Text(rightText,
            style: GlobalsStyle.settingsRightTextStyle
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.darkBlack,
          elevation: 0,
        ),
        onPressed: () {
          SignOutDialog().buildSignOutDialog(
            context: context, 
            signOutOnPressed: () async {
              _clearUserStorageData();
              await _deleteAutoLoginAndOfflineFiles();

              if(!mounted) return;
              NavigatePage.replacePageMain(context);
            }
          );
        },
        child: const Text("Logout from my account",
          style: TextStyle(
            fontSize: 17,
            color: Colors.redAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildRowWithButtons({
    required String topText, 
    required String bottomText, 
    required VoidCallback onPressed
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              onTap: onPressed,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 5),

                  Text(
                    topText,
                    style: GlobalsStyle.settingsLeftTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    bottomText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ThemeColor.thirdWhite
                    ),
                  ),

                  const SizedBox(height: 5),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 14),
          child: Text(text,
            style: GlobalsStyle.settingsInfoTextStyle
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          children: [
      
            const SizedBox(height: 5),
      
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        custUsername.substring(0, 2),
                        style: const TextStyle(
                          fontSize: 24,
                          color: ThemeColor.darkPurple,
                        ),
                      ),
                    ),
                  ),
                ),
      
                const SizedBox(width: 5),
      
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: custUsername));
                        CallToast.call(message: "Username copied.");
                      },
                      child: Text(
                        custUsername,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      accountType,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 185, 185, 185),
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
      
                const Spacer(),

                SizedBox(
                  width: 112,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      NavigatePage.goToPageUpgrade();
                    },
                    style: GlobalsStyle.btnMainStyle,
                    child: const Text('Upgrade'),
                  ),
                ),

                const SizedBox(width: 10),

              ],
            ),
      
            const SizedBox(height: 10),
      
            _buildInfoText("Account Information"),
      
            _buildRow("Email",custEmail),
            _buildRow("Account Type",accountType),
            _buildRow("Upload Limit",uploadLimit.toString()),
            
            const SizedBox(height: 15),
      
            _buildInfoText("Update Information"),
      
            const SizedBox(height: 8),
      
            _buildRowWithButtons(
              topText: "Change my password", 
              bottomText: "Update your Flowstorage password", 
              onPressed: () {
                NavigatePage.goToPageChangePass(context);
              }
            ),
      
            const SizedBox(height: 15),
      
            _buildInfoText("Sharing"),
      
            const SizedBox(height: 8),
      
            _buildRowWithButtons(
              topText: "File sharing", 
              bottomText: sharingEnabledButton, 
              onPressed: () async {

                sharingEnabledButton == 'Disable' 
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
                CustomAlertDialog.alertDialogTitle("Sharing $sharingStatus", conclusionSubMsg);
              }
            ),
      
            const SizedBox(height: 10),
      
            _buildRowWithButtons(
              topText: "Configure password", 
              bottomText: "Require password for file sharing with you", 
              onPressed: () async {
                NavigatePage.goToPageCongfigureSharingPassword();
              }
            ),
      
            const SizedBox(height: 15),
      
            _buildInfoText("Security"),
      
            const SizedBox(height: 8),
      
            _buildRowWithButtons(
              topText: "Configure passcode", 
              bottomText: "Require to enter passcode before allowing to \nopen Flowstorage", 
              onPressed: () async {
                NavigatePage.goToPageCongfigurePasscode();
              }
            ),

            const SizedBox(height: 15),

            _buildRowWithButtons(
              topText: "Backup recovery key", 
              bottomText: "Recovery key enables password reset in case of forgotten passwords", 
              onPressed: () async {
                NavigatePage.goToPageBackupRecovery();
              }
            ),

            const SizedBox(height: 15),
      
            _buildInfoText("Insight"),
      
            const SizedBox(height: 8),
      
            _buildRowWithButtons(
              topText: "Statistics", 
              bottomText: "Get more insight about your Flowstorage activity", 
              onPressed: () async {

                if(tempData.origin != OriginFile.home) {
                  await dataCaller.homeData(isFromStatistics: true);
                }

                if(!mounted) return;
                NavigatePage.goToPageStatistics();

              }
            ),

            const SizedBox(height: 20),
      
            _buildInfoText("Flowstorage"),
      
            const SizedBox(height: 8),
      
            _buildRowWithButtons(
              topText: "App version", 
              bottomText: "2.1.4", 
              onPressed: () {}
            ),

            const SizedBox(height: 15),

            _buildRowWithButtons(
              topText: "Rate us", 
              bottomText: "Rate your experience with Flowstorage", 
              onPressed: () { }
            ),

            const SizedBox(height: 15),

            _buildRowWithButtons(
              topText: "Clear cache", 
              bottomText: "Clear Flowstorage cache", 
              onPressed: () {
                _clearAppCache();
                CallToast.call(message: "Cache cleared.");
              }
            ),

            const SizedBox(height: 10),

            Visibility(
              visible: accountType != "Basic",
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  _buildInfoText("Plan"),
                  
                  const SizedBox(height: 10),
                  
                  _buildRowWithButtons(
                    topText: "My plan", 
                    bottomText: "See your subscription plan details", 
                    onPressed: () async {
                      NavigatePage.goToPageMyPlan();
                    }
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildLogoutButton(),
      
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      appBar: AppBar(
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
        title: const Text(
          'Settings',
          style: GlobalsStyle.appBarTextStyle
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(context),
    );
  }

  @override
  void initState() {
    super.initState();
    custUsername = widget.custUsername;
    custEmail = widget.custEmail;
    accountType = widget.accType;
    uploadLimit = widget.uploadLimit;
    sharingEnabledButton = widget.sharingEnabledButton == '0' ? 'Disable' : 'Enable';
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _buildTabs(context),
    );
  }

}

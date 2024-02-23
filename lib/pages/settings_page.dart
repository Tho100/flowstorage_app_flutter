import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_classes/data_caller.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/interact_dialog/signout_dialog.dart';
import 'package:flowstorage_fsc/models/local_storage_model.dart';
import 'package:flowstorage_fsc/models/profile_picture_model.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();

}

class SettingsPageState extends State<SettingsPage> {

  final dataCaller = DataCaller();

  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();
  
  final profilePicNotifier = ValueNotifier<Uint8List?>(Uint8List(0));

  void _onCreateProfilePicPressed() async {
    
    final isProfileSelected = await ProfilePictureModel()
        .createProfilePicture();

    if(isProfileSelected) {
      final profilePicture = await ProfilePictureModel()
        .loadProfilePic();

      profilePicNotifier.value = profilePicture;

      userData.setProfilePictureEnabled(false);
      userData.setProfilePicture(profilePicture!);

      CallToast.call(message: "Updated profile picture");

    }

  }

  void _clearUserStorageData() {
    storageData.fileNamesList.clear();
    storageData.fileNamesFilteredList.clear();
    storageData.fileDateList.clear();
    storageData.imageBytesList.clear();
    storageData.imageBytesFilteredList.clear();
    tempStorageData.folderNameList.clear();
  }

  Widget _buildButtons(String title, String subheader, IconData icon, VoidCallback onPressed, {Color? customColor}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16.0),
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero
        )
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: customColor ?? ThemeColor.darkPurple,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon, 
              size: 20.0,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: ThemeColor.secondaryWhite, 
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subheader,
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: ThemeColor.thirdWhite, 
                ),
              ),
            ],
          ),
        ],
      ),
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
      
            Container(
              width: MediaQuery.of(context).size.width-25,
              height: 85,
              decoration: BoxDecoration(
                color: ThemeColor.darkBlack,
                border: Border.all(
                  color: ThemeColor.lightGrey
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: GestureDetector(
                      onTap: () async {
                        _onCreateProfilePicPressed();
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ProfilePicture(
                            notifierValue: profilePicNotifier
                          ),
                          if(profilePicNotifier.value!.isNotEmpty)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(90, 0, 0, 0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_camera_rounded, 
                              color: ThemeColor.justWhite,
                              size: 16,
                            ),
                          ),
                        ],
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
                          Clipboard.setData(ClipboardData(text: userData.username));
                          CallToast.call(message: "Username copied.");
                        },
                        child: Text(
                          userData.username,
                          style: const TextStyle(
                            color: ThemeColor.justWhite,
                            fontSize: 18.5,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        userData.accountType,
                        style: const TextStyle(
                          color: ThemeColor.thirdWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
            
                  SizedBox(
                    width: 115,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        NavigatePage.goToPageUpgrade();
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: ThemeColor.justWhite,
                      ),
                      child: const Text('Upgrade',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: ThemeColor.darkBlack
                        ),
                      ),
                    ),
                  ),
            
                  const SizedBox(width: 10),
            
                ],
              ),
            ),
      
            const SizedBox(height: 20),
            
            _buildButtons(
              "Account", 
              "Account information and more", 
              Icons.person, () {
                NavigatePage.goToPageSettingsAccount();
              }
            ),

            _buildButtons(
              "Sharing", 
              "Update sharing configuration", 
              Icons.share, () {
                NavigatePage.goToSettingsSharingPage();
              }
            ),

            _buildButtons(
              "Security", 
              "Passcode and recovery key", 
              Icons.shield, () {
                NavigatePage.goToSecurityPage();
              }
            ),

            _buildButtons(
              "Statistics", 
              "Insight about your Flowstorage activity", 
              Icons.bar_chart, () async {
                if(tempData.origin != OriginFile.home) {
                  await dataCaller.statisticsData();
                }

                NavigatePage.goToPageStatistics();
              }
            ),

            _buildButtons(
              "App Settings", 
              "Permissions, cache and more", 
              Icons.info_outline, () {
                NavigatePage.goToPageSettingsAppSettings();
              }
            ),

            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0),
              child: Divider(color: ThemeColor.lightGrey),
            ),

            _buildButtons(
              "Sign Out", 
              "Sign out from your account", 
              Icons.logout, () async {
                SignOutDialog().buildSignOutDialog(
                  context: context, 
                  signOutOnPressed: () async {
                    _clearUserStorageData();
                    await LocalStorageModel()
                      .deleteAutoLoginAndOfflineFiles(userData.username, false);

                    if(mounted) {
                      NavigatePage.replacePageMain(context);
                    }
                  }
                );
              },
              customColor: ThemeColor.darkRed
            ),
      
          ],
        ),
      ),
    );
  }

  Future<void> initializeProfilePic() async {
    
    try {

      profilePicNotifier.value = await ProfilePictureModel().getProfilePicData();

    } catch (err) {
      profilePicNotifier.value = Uint8List(0);

    }

  }

  @override
  void initState() {
    super.initState();
    initializeProfilePic();
  }

  @override 
  void dispose() {
    profilePicNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
        title: const Text(
          'Settings',
          style: GlobalsStyle.appBarTextStyle
        ),
      ),
      body: _buildBody(context),
    );
  }

}

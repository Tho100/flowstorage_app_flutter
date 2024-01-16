import 'dart:typed_data';

import 'package:flowstorage_fsc/models/local_storage_model.dart';
import 'package:flowstorage_fsc/models/profile_picture_model.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UserAccountsPage extends StatefulWidget {

  const UserAccountsPage({super.key});

  @override
  State<UserAccountsPage> createState() => UserAccountsPageState();
}

class UserAccountsPageState extends State<UserAccountsPage> {

  List<String> localAccountUsernamesList = [];
  List<String> localAccountPlansList = [];
  List<String> localAccountGmailList = [];

  final profilePicNotifier = ValueNotifier<Uint8List?>(Uint8List(0));

  final userData = GetIt.instance<UserDataProvider>();

  Widget _buildLocalAccountListView() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: localAccountUsernamesList.length,
      itemExtent: 70,
      itemBuilder: (context, index) {
        return ListTile(
          leading: localAccountUsernamesList[index] == userData.username 
          ? ProfilePicture(
            notifierValue: profilePicNotifier,
            customWidth: 45,
            customHeight: 45,
            customBackgroundColor: ThemeColor.justWhite,
            customOnEmpty: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                localAccountUsernamesList[index][0],
                style: const TextStyle(
                  color: ThemeColor.darkPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
          : Container(
            width: 45,
            height: 45,
            decoration: const BoxDecoration(
              color: ThemeColor.justWhite,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                localAccountUsernamesList[index][0],
                style: const TextStyle(
                  color: ThemeColor.darkPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          title: Text(localAccountUsernamesList[index] == userData.username 
              ? "${localAccountUsernamesList[index]} (Current)" 
              : localAccountUsernamesList[index],
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontSize: 17,
              fontWeight: FontWeight.w600
            ),
          ),
          subtitle: Text("${localAccountPlansList[index]} ${GlobalsStyle.dotSeperator} ${localAccountGmailList[index]}", 
            style: const TextStyle(
              color: ThemeColor.thirdWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600
            ),
          ),
        );
      },      
    );
  }

  Widget buildBody() {
    return FutureBuilder<void>(
      future: _readLocalAccountData(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          return Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 12),
            child: _buildLocalAccountListView(),
          );

        } else {
          return const CircularProgressIndicator(color: ThemeColor.darkPurple);

        }
      }
    );
  }

  Future<void> _readLocalAccountData() async {
    final localStorageModel = LocalStorageModel();
    final usernames = await localStorageModel.readLocalAccountUsernames();
    final emails = await localStorageModel.readLocalAccountEmails();
    final plans = await localStorageModel.readLocalAccountPlans();
    localAccountUsernamesList.addAll(usernames);
    localAccountGmailList.addAll(emails);
    localAccountPlansList.addAll(plans);
  }

  Future<void> _initializeProfilePic() async {
    
    try {

      final picData = await ProfilePictureModel().loadProfilePic();

      if(picData == null) {
        profilePicNotifier.value = Uint8List(0);
        
      } else {
        profilePicNotifier.value = picData;

      }

    } catch (error) {
      profilePicNotifier.value = Uint8List(0);

    }

  }

  @override
  void initState() {
    super.initState();
    _initializeProfilePic();
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
        title: const Text("My accounts",
          style: GlobalsStyle.appBarTextStyle,
        ),
      ),
      body: buildBody(),
    );
  }
}
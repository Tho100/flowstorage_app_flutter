import 'dart:typed_data';

import 'package:flowstorage_fsc/models/local_storage_model.dart';
import 'package:flowstorage_fsc/models/profile_picture_model.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/profile_picture.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final localStorageModel = LocalStorageModel();

  Widget _buildLocalAccountListView() {

    const titleTextStyle = TextStyle(
      color: ThemeColor.secondaryWhite,
      fontSize: 17,
      fontWeight: FontWeight.bold
    );

    const subtitleTextStyle = TextStyle(
      color: ThemeColor.thirdWhite,
      fontSize: 14,
      fontWeight: FontWeight.w600
    );

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
              padding: const EdgeInsets.only(top: 9.0),
              child: Text(
                localAccountUsernamesList[index].substring(0, 2),
                style: GoogleFonts.inter(
                  color: ThemeColor.darkPurple,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
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
              padding: const EdgeInsets.only(top: 9.0),
              child: Text(
                localAccountUsernamesList[index].substring(0, 2),
                style: GoogleFonts.inter(
                  color: ThemeColor.darkPurple,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          title: localAccountUsernamesList[index] == userData.username 
          ? Row(
            children: [
              Text(localAccountUsernamesList[index],
                style: titleTextStyle,
              ),
              const Spacer(),
              Transform.translate(
                offset: const Offset(0, 4),
                child: const Padding( 
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(CupertinoIcons.checkmark_alt_circle_fill, 
                    color: ThemeColor.darkPurple,
                    size: 26,
                  ),
                ),
              ),
            ],
          )
          : Text(localAccountUsernamesList[index],
            style: titleTextStyle,
          ),
          subtitle: Text("${localAccountPlansList[index]} ${GlobalsStyle.dotSeparator} ${localAccountGmailList[index]}", 
            style: subtitleTextStyle,
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

    final myAccounts = await LocalStorageModel().readMyAccounts();

    final usernames = myAccounts['usernames']!;
    final emails = myAccounts['emails']!;
    final plans = myAccounts['plans']!;
    
    localAccountUsernamesList.addAll(usernames);
    localAccountGmailList.addAll(emails);
    localAccountPlansList.addAll(plans);

  }

  Future<void> _initializeProfilePic() async {
    
    try {

      profilePicNotifier.value = await ProfilePictureModel().getProfilePicData();

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
      appBar: CustomAppBar(
        context: context,
        title: "My Accounts"
      ).buildAppBar(),
      body: buildBody(),
    );
  }
  
}
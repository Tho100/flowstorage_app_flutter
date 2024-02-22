import 'dart:typed_data';

import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/profile_picture.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MyAccountsDialog {

  final List<String> localAccountUsernamesList;
  final List<String> localAccountPlansList;
  final List<String> localAccountGmailList;

  final ValueNotifier<Uint8List?> profilePicNotifier;

  MyAccountsDialog({
    required this.localAccountUsernamesList,
    required this.localAccountPlansList,
    required this.localAccountGmailList,
    required this.profilePicNotifier
  });

  final userData = GetIt.instance<UserDataProvider>();

  final titleTextStyle = const TextStyle(
    color: ThemeColor.secondaryWhite,
    fontSize: 17,
    fontWeight: FontWeight.w600
  );

  final subtitleTextStyle = const TextStyle(
    color: ThemeColor.thirdWhite,
    fontSize: 14,
    fontWeight: FontWeight.w500
  );

  Future buildMyAccountsBottomSheet() {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkBlack,
      context: navigatorKey.currentContext!,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,  
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              
              const SizedBox(height: 12),

              const BottomSheetBar(),

              const BottomTrailingTitle(title: "My Accounts"),

              const Divider(color: ThemeColor.lightGrey),

              Expanded(  
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: localAccountUsernamesList.length,
                  itemExtent: 70,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: localAccountUsernamesList[index] == userData.username 
                      ? _buildProfilePicture(index)
                      : _buildDefaultProfilePicture(index),

                      title: localAccountUsernamesList[index] == userData.username 
                      ? _buildCurrentAccount(index)
                      : Text(localAccountUsernamesList[index],
                        style: titleTextStyle,
                      ),
                      
                      subtitle: Text("${localAccountPlansList[index]} ${GlobalsStyle.dotSeparator} ${localAccountGmailList[index]}", 
                        style: subtitleTextStyle,
                      ),
                    );
                  },      
                ),
              ),

            ],
          ),
        );
      }
    );

  }

  Widget _buildCurrentAccount(int index) {
    return Row(
      children: [
        Text(localAccountUsernamesList[index],
          style: titleTextStyle,
        ),
        const Spacer(),
        const Padding( 
          padding: EdgeInsets.only(right: 12.0),
          child: Icon(Icons.check_circle_rounded, color: ThemeColor.darkPurple),
        ),
      ],
    );
  }

  Widget _buildProfilePicture(int index) {
    return ProfilePicture(
      notifierValue: profilePicNotifier,
      customWidth: 45,
      customHeight: 45,
      customBackgroundColor: ThemeColor.justWhite,
      customOnEmpty: Padding(
        padding: const EdgeInsets.only(top: 9.0),
        child: Text(
          localAccountUsernamesList[index].substring(0, 2),
          style: const TextStyle(
            color: ThemeColor.darkPurple,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDefaultProfilePicture(int index) {
    return Container(
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
          style: const TextStyle(
            color: ThemeColor.darkPurple,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

}
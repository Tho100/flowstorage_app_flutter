import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CustomSideBarMenu extends StatelessWidget {

  final Future<int> usageProgress;
  final VoidCallback offlinePageOnPressed;

  CustomSideBarMenu({
    required this.usageProgress,
    required this.offlinePageOnPressed,
    Key? key
  }) : super(key: key);

  final userData = GetIt.instance<UserDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  Widget _buildSidebarButtons({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: ThemeColor.secondaryWhite,
        child: Ink(
          color: ThemeColor.darkBlack,
          child: ListTile(
            horizontalTitleGap: 0,
            contentPadding: const EdgeInsets.only(left: 22),
            leading: Icon(
              icon,
              color: const Color.fromARGB(255, 215, 215, 215),
              size: 21,
            ),
            title: Text(
              title,
              style: GlobalsStyle.sidebarMenuButtonsStyle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomRight: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
      child: Drawer(
        child: Container(
          color: ThemeColor.darkBlack,
            child: Column(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: ThemeColor.darkBlack,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            userData.username != "" ? userData.username.substring(0, 2) : "",
                            style: const TextStyle(
                              fontSize: 24,
                              color: ThemeColor.darkPurple,
                            ),
                          ),
                        ),
                      ),
    
                      const SizedBox(width: 15),
    
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userData.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              userData.email,
                              style: const TextStyle(
                                color: Color.fromARGB(255,185,185,185),
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ElevatedButton(
                    onPressed: () {
                      NavigatePage.goToPageUpgrade(context);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: ThemeColor.darkPurple,
                    ),
                    child: const Text(
                      'Get more storage',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
    
                const SizedBox(height: 15),
    
                const Divider(color: ThemeColor.lightGrey),
    
                Expanded(
                  child: ListView(
                    children: [
    
                      _buildSidebarButtons(
                        title: "Offline",
                        icon: Icons.offline_bolt_outlined,
                        onPressed: () {
                          Navigator.pop(context);
                          offlinePageOnPressed();
                        }
                      ),
    
                      _buildSidebarButtons(
                        title: "Upgrade plan",
                        icon: Icons.rocket_outlined,
                        onPressed: () async {
                          Navigator.pop(context);
                          NavigatePage.goToPageUpgrade(context);
                        }
                      ),
    
                      _buildSidebarButtons(
                        title: "Settings",
                        icon: Icons.settings_outlined,
                        onPressed: () async {
                          Navigator.pop(context);
                          NavigatePage.goToPageSettings(context);
                        }
                      ),
    
                    ],
                  ),
                ),
    
                if(tempData.origin != OriginFile.public && tempData.origin != OriginFile.offline) ... [ 
                  
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 22.0),
                      child: Row(
                        children: [
                          Icon(Icons.cloud_outlined, color: Color.fromARGB(255, 215, 215, 215), size: 20),
                          SizedBox(width: 10),
                          Text(
                            "Storage Usage",
                            style: TextStyle(
                              color: Color.fromARGB(255, 218, 218, 218),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.only(right: 25.0),
                      child: FutureBuilder<int>(
                        future: usageProgress,
                        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                          return Text(
                            "${snapshot.data.toString()}%",
                            style: const TextStyle(
                              color: Color.fromARGB(255, 218, 218, 218),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          );
                        }
                      ),
                    ),
                  ],
                ),
    
                Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 14.0, top: 8.0),
                  child: Container(
                    height: 10,
                    width: 265,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: ThemeColor.darkBlack,
                        width: 2.0,
                      ),
                    ),
                    child: FutureBuilder<int>(
                      future: usageProgress,
                      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const LinearProgressIndicator(
                            backgroundColor: ThemeColor.lightGrey,
                          );
                        }
                        final progressValue = snapshot.data! / 100.0;
                        return LinearProgressIndicator(
                          backgroundColor: ThemeColor.lightGrey,
                          valueColor: AlwaysStoppedAnimation<Color>(progressValue > 0.70 ? ThemeColor.darkRed : ThemeColor.darkPurple),
                          value: progressValue,
                        );
                      },
                    ),
                  ),
                ),
              ],
                
            ],
          ),
        ),
      ),
    );
  }
}
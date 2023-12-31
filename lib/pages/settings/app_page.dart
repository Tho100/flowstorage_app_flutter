import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

class SettingsAppSettings extends StatelessWidget {

  SettingsAppSettings({super.key});

  void _clearAppCache() async {
    final cacheDir = await getTemporaryDirectory();
    await DefaultCacheManager().emptyCache();
    cacheDir.delete(recursive: true);
  }

  static final userData = GetIt.instance<UserDataProvider>();

  final accountType = userData.accountType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
        title: const Text("App Settings",
          style: GlobalsStyle.appBarTextStyle,
        ),
      ),
      body: Column(
        children: [
          
          const SizedBox(height: 8),

          SettingsButton(
            hideCaret: true,
            topText: "App version", 
            bottomText: "2.1.4", 
            onPressed: () {}
          ),

          SettingsButton(
            topText: "Rate us", 
            bottomText: "Rate your experience with Flowstorage", 
            onPressed: () { }
          ),

          SettingsButton(
            hideCaret: true,
            topText: "Clear cache", 
            bottomText: "Clear Flowstorage cache", 
            onPressed: () {
              _clearAppCache();
              CallToast.call(message: "Cache cleared.");
            }
          ),

          Visibility(
            visible: accountType != "Basic",
            child: Column(
              children: [

                const SizedBox(height: 20),
                                                
                SettingsButton(
                  topText: "My plan", 
                  bottomText: "See your subscription plan details", 
                  onPressed: () async {
                    NavigatePage.goToPageMyPlan();
                  }
                ),
              ],
            )
          ),
                  
        ],
      ),
    );
  }
}
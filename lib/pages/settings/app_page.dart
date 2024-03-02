import 'package:app_settings/app_settings.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/buttons/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

class SettingsAppSettings extends StatelessWidget {

  const SettingsAppSettings({super.key});

  void _clearAppCache() async {
    final cacheDir = await getTemporaryDirectory();
    await DefaultCacheManager().emptyCache();
    cacheDir.delete(recursive: true);
  }

  static final userData = GetIt.instance<UserDataProvider>();

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
            topText: "Configure notification", 
            bottomText: "Configure Flowstorage notification settings", 
            onPressed: () {
              AppSettings.openAppSettings(type: AppSettingsType.notification);
            }
          ),

          SettingsButton(
            topText: "Configure permissions", 
            bottomText: "Configure Flowstorage permissions settings", 
            onPressed: () {
              AppSettings.openAppSettings(type: AppSettingsType.settings);
            }
          ),

          const Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Divider(color: ThemeColor.lightGrey),
          ),

          const SizedBox(height: 5),

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

          const SizedBox(height: 5),

          const Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 18.0, top: 8, bottom: 8),
                child: Text("App version",
                  style: GlobalsStyle.settingsLeftTextStyle
                ),
              ),

              Spacer(),

              Padding(
                padding: EdgeInsets.only(right: 18.0, top: 8, bottom: 8),
                child: Text("2.1.4",
                  style: TextStyle(
                    fontSize: 17,
                    color: ThemeColor.thirdWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
                  
        ],
      ),
    );
  }
}
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/buttons/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

class SettingsAppSettings extends StatelessWidget {

  const SettingsAppSettings({super.key});

  static final userData = GetIt.instance<UserDataProvider>();

  Future<int> _getCacheSize() async {

    final tempDir = await getTemporaryDirectory();
    final tempDirSize = _processCacheSize(tempDir);

    return tempDirSize;

  }

  int _processCacheSize(FileSystemEntity file) {

    if (file is File) {
      return file.lengthSync();

    } else if (file is Directory) {
      int sum = 0;

      final children = file.listSync();
      for (FileSystemEntity child in children) {
        sum += _processCacheSize(child);
      }

      return sum;

    }
    
    return 0;

  }

  void _clearAppCache() async {
    
    final cacheSizeInMb = await _getCacheSize() / (1024 * 1024);
    
    await DefaultCacheManager().emptyCache();

    final tempDir = await getTemporaryDirectory();

    if(tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }

    CallToast.call(message: "Cleared ${cacheSizeInMb.toDouble().toStringAsFixed(2)} Mb");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context, 
        title: "App Settings"
      ).buildAppBar(),
      body: Column(
        children: [
          
          const SizedBox(height: 8),

          SettingsButton(
            topText: "Configure notification", 
            bottomText: "Configure Flowstorage notification settings", 
            onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.notification),
          ),

          SettingsButton(
            topText: "Configure permissions", 
            bottomText: "Configure Flowstorage permissions settings", 
            onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.settings),
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
            bottomText: "Free up storage space by clearing cache", 
            onPressed: () => _clearAppCache(),
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
                    fontWeight: FontWeight.w600,
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
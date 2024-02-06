import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/default_switch.dart';
import 'package:flowstorage_fsc/widgets/buttons/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConfigurePasscodePage extends StatefulWidget {
  const ConfigurePasscodePage({super.key});

  @override
  State<ConfigurePasscodePage> createState() => ConfigurePasscodePageState();
}

class ConfigurePasscodePageState extends State<ConfigurePasscodePage> {

  final storage = const FlutterSecureStorage();
  
  bool isPasscodeEnabled = false;

  void togglePasscode(String value) async {
    await storage.write(key: "isEnabled", value: value);
  }

  Widget buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 18.0), 
          child: Row(
            children: [
              const Text(
                "Enable passcode",
                style: GlobalsStyle.settingsLeftTextStyle,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              DefaultSwitch(
                value: isPasscodeEnabled, 
                onChanged: (value) async {
                  setState(() {
                    isPasscodeEnabled = value;
                  });
                          
                  final isPassCodeExists = await storage.containsKey(key: 'key0015');
                          
                  if (!isPassCodeExists) {
                    isPasscodeEnabled = false;
                    if(mounted) {
                      NavigatePage.goToAddPasscodePage();
                    }
                          
                  } else {
                    final isEnabled = isPasscodeEnabled.toString();
                    togglePasscode(isEnabled);
                          
                  }
                }
              ),
              
            ],
          ),
        ),

        const SizedBox(height: 8),

        Visibility(
          visible: isPasscodeEnabled,
          child: SettingsButton(
            topText: "Edit passcode", 
            bottomText: "Update your current passcode", 
            onPressed: () {
              NavigatePage.goToAddPasscodePage();
            }
          ),
        ),

      ],
    
    );
  }

  Future<void> _loadPasscodeStatus() async {
    
    bool isPasscodeExist = await storage.containsKey(key: 'key0015');

    if(isPasscodeExist) {
      final isEnabled = await storage.read(key: 'isEnabled');
      setState(() {
        isPasscodeEnabled = isEnabled == "true";
      });

    } else {
      setState(() {
        isPasscodeEnabled = false;
      });

    }
  }

  @override
  void initState() {
    super.initState();
    _loadPasscodeStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        title: const Text("Configure passcode",
          style: GlobalsStyle.appBarTextStyle,
        ),
      ),
      body: buildBody(),
    );
  }
}
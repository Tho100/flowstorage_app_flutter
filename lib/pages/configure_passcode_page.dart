import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 2.0), 
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Enable passcode",
                        style: GlobalsStyle.settingsLeftTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      Switch(
                        inactiveThumbColor: ThemeColor.darkPurple,
                        activeColor: ThemeColor.darkPurple,
                        value: isPasscodeEnabled,
                        onChanged: (value) async {
                          setState(() {
                            isPasscodeEnabled = value;
                          });

                          bool isPassCodeExists = await storage.containsKey(key: 'key0015');

                          if (!isPassCodeExists) {
                            isPasscodeEnabled = false;
                            if (!mounted) return;
                            NavigatePage.goToAddPasscodePage(context);

                          } else {
                            final isEnabled = isPasscodeEnabled ? "true" : "false";
                            togglePasscode(isEnabled);

                          }

                        },
                      ),

                    ],
                  ),
                ),
              ],
            ),
          ),

          Visibility(
            visible: isPasscodeEnabled,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        NavigatePage.goToAddPasscodePage(context);
                      },
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            "Edit passcode",
                            style: GlobalsStyle.settingsLeftTextStyle,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Edit current passcode",
                            style: TextStyle(fontSize: 13,fontWeight: FontWeight.w500,color: ThemeColor.thirdWhite),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
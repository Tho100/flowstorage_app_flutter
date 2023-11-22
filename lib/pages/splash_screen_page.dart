import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_classes/data_caller.dart';
import 'package:flowstorage_fsc/data_classes/user_data_retriever.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/folder_query/folder_name_retriever.dart';
import 'package:flowstorage_fsc/models/quick_actions_model.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_actions/quick_actions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  final selectedActionNotifier = ValueNotifier<String>('');

  final logger = Logger();

  final encryption = EncryptionClass();
  final accountInformationRetriever = UserDataRetriever();
  final quickActionsModel = QuickActionsModel();
  
  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final tempData = GetIt.instance<TempDataProvider>();
  
  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  final crud = Crud();
  
  Timer? splashScreenTimer;

  @override
  void initState() {
    super.initState();
    _initializeQuickActions();
    _startTimer();
  }

  void _initializeQuickActions() async {

    const quickActions = QuickActions();

    const storage = FlutterSecureStorage();
    bool isPassCodeExists = await storage.containsKey(key: "key0015");

    quickActions.initialize((String shortcutType) async {

      selectedActionNotifier.value = shortcutType;

      final getLocalUsername = (await _retrieveLocallyStoredInformation())[0];

      if(getLocalUsername.isNotEmpty) {

        if(shortcutType == newDirectoryAction && isPassCodeExists == false) {
          await _navigateToNextScreen();
          quickActionsModel.newDirectory();          

        } else if (shortcutType == goOfflinePageAction) {
          await quickActionsModel.offline();          
          setState(() {});

        } 
        
      } else {
        if(!mounted) return;
        NavigatePage.replacePageMain(context);
      }
    
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: newDirectoryAction,
        localizedTitle: 'Create Directory',
        icon: 'dir_icon'
      ),
      const ShortcutItem(
        type: goOfflinePageAction,
        localizedTitle: 'Offline',
        icon: 'off_icon'
      ),
    ]);

  }

  void _startTimer() async {
    
    if ((await _retrieveLocallyStoredInformation())[0] != '') {
      splashScreenTimer = Timer(const Duration(milliseconds: 0), () {
        _navigateToNextScreen();
      });
    } else {
      splashScreenTimer = Timer(const Duration(milliseconds: 1895), () {
        _navigateToNextScreen();
      });
    }
    
  }

  Future<void> _navigateToNextScreen() async {

    try {

      final getLocalUsername = (await _retrieveLocallyStoredInformation())[0];
      final getLocalEmail = (await _retrieveLocallyStoredInformation())[1];
      final getLocalAccountType = (await _retrieveLocallyStoredInformation())[2];

      if(getLocalUsername == '') {

        if(!mounted) return;
        NavigatePage.replacePageMain(context);

      } else {

        const storage = FlutterSecureStorage();
        bool isPassCodeExists = await storage.containsKey(key: "key0015");

        final isPasscodeEnabled = await storage.read(key: "isEnabled");

        userData.setAccountType(getLocalAccountType);
        userData.setUsername(getLocalUsername);
        userData.setEmail(getLocalEmail);

        selectedActionNotifier.value == goOfflinePageAction 
            ? tempData.setOrigin(OriginFile.offline) 
            : tempData.setOrigin(OriginFile.home);

        if(isPassCodeExists && isPasscodeEnabled == "true") {
          
          await Future.delayed(const Duration(milliseconds: 850));

          if(!mounted) return;
          NavigatePage.goToPagePasscode(context);

        } else {

          final conn = await SqlConnection.initializeConnection();
          
          if(!mounted) return;
          
          await _callFileData(
            conn, getLocalUsername, getLocalEmail, 
            getLocalAccountType, context);
          
          if(!mounted) return;
          NavigatePage.permanentPageMainboard(context);
          
        }
      }

    } catch (err, st) {
      logger.e("Exception from _navigateToNextScreen {SplashScreen}",err, st);
      NavigatePage.replacePageMain(context);
    }

  }

  Future<List<String>> _retrieveLocallyStoredInformation() async {
    
    String username = '';
    String email = '';
    String accountType = '';

    final getDirApplication = await getApplicationDocumentsDirectory();
    final setupPath = '${getDirApplication.path}/FlowStorageInfos';
    final setupInfosDir = Directory(setupPath);

    if (setupInfosDir.existsSync()) {
      final setupFiles = File('${setupInfosDir.path}/CUST_DATAS.txt');

      if (setupFiles.existsSync()) {
        final lines = await setupFiles.readAsLines();

        if (lines.length >= 2) {
          username = lines[0];
          email = lines[1];
          accountType = lines[2];
        }
      }
    }

    List<String> accountInfo = [];
    accountInfo.add(encryption.decrypt(username));
    accountInfo.add(encryption.decrypt(email));
    accountInfo.add(accountType);

    return accountInfo;

  }

  Future<void> _callFileData(MySQLConnectionPool conn, String savedCustUsername, String savedCustEmail, String savedAccountType,BuildContext context) async {

    try {

      userData.setUsername(savedCustUsername);
      userData.setEmail(savedCustEmail);
      
      final accountType = await accountInformationRetriever.retrieveAccountType(email: savedCustEmail);
      
      userData.setAccountType(accountType);
      
      final futures = await DataCaller().startupDataCaller(
        conn: conn, username: savedCustUsername);

      final results = await Future.wait(futures);

      final fileNames = <String>{};
      final bytes = <Uint8List>[];
      final dates = <String>[];
      final retrieveFolders = <String>{};

      if (await crud.countUserTableRow(GlobalsTable.folderUploadTable) > 0) {
        retrieveFolders.addAll(await FolderRetriever().retrieveParams(savedCustUsername));
      }

      for (final result in results) {
        final fileNamesForTable = result[0] as List<String>;
        final bytesForTable = result[1] as List<Uint8List>;
        final datesForTable = result[2] as List<String>;

        fileNames.addAll(fileNamesForTable);
        bytes.addAll(bytesForTable);
        dates.addAll(datesForTable);
      }

      final uniqueFileNames = fileNames.toList();
      final uniqueBytes = bytes.toList();
      final uniqueFolders = retrieveFolders.toList();

      storageData.setFilesName(uniqueFileNames);
      storageData.setImageBytes(uniqueBytes);
      storageData.setFilesDate(dates);

      tempStorageData.setFoldersName(uniqueFolders);
      
    } catch (err) {
      NavigatePage.replacePageMain(context);
      return;
    }

  }

  @override
  void dispose() {
    splashScreenTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSplashScreen(context),
    );
  }

  Widget _buildSplashScreen(BuildContext context) {
    return Container(
     color: ThemeColor.darkPurple,
      child: Align(
        alignment: Alignment.center,
        child: Center(
          child: SizedBox(
            height: 90,
            child: Image.asset(
              'assets/images/splash_logo.jpg',
            ),
          ),  
        ),
      ),
    );
  }

}
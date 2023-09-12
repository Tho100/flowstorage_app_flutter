import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_classes/data_caller.dart';
import 'package:flowstorage_fsc/data_classes/user_data_retriever.dart';
import 'package:flowstorage_fsc/directory_query/create_directory.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/extra_query/crud.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/data_classes/date_getter.dart';
import 'package:flowstorage_fsc/data_classes/data_retriever.dart';
import 'package:flowstorage_fsc/data_classes/files_name_retriever.dart';
import 'package:flowstorage_fsc/folder_query/folder_name_retriever.dart';
import 'package:flowstorage_fsc/interact_dialog/create_directory_dialog.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_actions/quick_actions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  final selectedActionNotifier = ValueNotifier<String>('');

  final logger = Logger();

  final nameGetterStartup = NameGetter();
  final dataGetterStartup = DataRetriever();
  final dateGetterStartup = DateGetter();
  final accountInformationRetriever = UserDataRetriever();

  final storageData = GetIt.instance<StorageDataProvider>();
  final userData = GetIt.instance<UserDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final crud = Crud();
  
  Timer? splashScreenTimer;

  @override
  void initState() {
    super.initState();
    _initializeQuickActions();
    _startTimer();
  }

  Future<void> _buildDirectory(String directoryName) async {

    try {

      await DirectoryClass().createDirectory(directoryName, userData.username);

      final directoryImage = await GetAssets().loadAssetsFile('dir1.png');

      setState(() {

        storageData.fileDateFilteredList.add("Directory");
        storageData.fileDateList.add("Directory");
        storageData.imageBytesList.add(directoryImage.readAsBytesSync());
        storageData.imageBytesFilteredList.add(directoryImage.readAsBytesSync());

      });

      storageData.directoryImageBytesList.clear();
      storageData.fileNamesFilteredList.add(directoryName);
      storageData.fileNamesList.add(directoryName);

      if (!mounted) return;
      SnakeAlert.okSnake(message: "Directory $directoryName has been created.", icon: Icons.check);

    } catch (err, st) {
      logger.e('Exception from _buildDirectory {main}',err,st);
      CustomAlertDialog.alertDialog('Failed to create directory.');
    }
  }

  void _openCreateDirectoryDialog() {
    CreateDirectoryDialog().buildCreateDirectoryDialog(
      context: context, 
      createOnPressed: () async {
        
        final getDirectoryTitle = CreateDirectoryDialog.directoryNameController.text.trim();

        if(getDirectoryTitle.isEmpty) {
          return;
        }

        if(storageData.fileNamesList.contains(getDirectoryTitle)) {
          CallToast.call(message: "Directory with this name already exists.");
          return;
        }

        await _buildDirectory(getDirectoryTitle);
        setState(() {});

        CreateDirectoryDialog.directoryNameController.clear();

      }

    );
  }

  void _initializeQuickActions() {

    const quickActions = QuickActions();

    quickActions.initialize((String shortcutType) async {

      selectedActionNotifier.value = shortcutType;

      final getLocalUsername = (await _retrieveLocallyStoredInformation())[0];

      if(getLocalUsername.isNotEmpty) {

        if(shortcutType == "new_dir") {

          await _navigateToNextScreen();

          _openCreateDirectoryDialog();

        } else if (shortcutType == "offline") {

          final dataCaller = DataCaller();
          await dataCaller.offlineData();

          setState(() {});

        } 
        
      } else {
        if(!mounted) return;
        NavigatePage.replacePageHome(context);
      }
    
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
        type: 'new_dir',
        localizedTitle: 'Create Directory',
        icon: 'dir_icon'
      ),
      const ShortcutItem(
        type: 'offline',
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
        NavigatePage.replacePageHome(context);

      } else {

        const storage = FlutterSecureStorage();
        bool isPassCodeExists = await storage.containsKey(key: "key0015");

        userData.setAccountType(getLocalAccountType);
        userData.setUsername(getLocalUsername);
        userData.setEmail(getLocalEmail);

        selectedActionNotifier.value == "offline" 
            ? tempData.setOrigin("offlineFiles") 
            : tempData.setOrigin("homeFiles");

        if(isPassCodeExists) {

          if(!mounted) return;
          NavigatePage.goToPagePasscode(context);

        } else {

          final conn = await SqlConnection.initializeConnection();

          if(!mounted) return;
          await _callData(conn, getLocalUsername, getLocalEmail, getLocalAccountType, context);
          
          if(!mounted) return;
          NavigatePage.permanentPageMainboard(context);
          
        }
      }
    } catch (err, st) {
      logger.e("Exception from _navigateToNextScreen {SplashScreen}",err, st);
      NavigatePage.replacePageHome(context);
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
        final lines = setupFiles.readAsLinesSync();

        if (lines.length >= 2) {
          username = lines[0];
          email = lines[1];
          accountType = lines[2];
        }
      }
    }

    List<String> accountInfo = [];
    accountInfo.add(EncryptionClass().decrypt(username));
    accountInfo.add(EncryptionClass().decrypt(email));
    accountInfo.add(accountType);

    return accountInfo;
  }

  Future<void> _callData(MySQLConnectionPool conn, String savedCustUsername, String savedCustEmail, String savedAccountType,BuildContext context) async {

    try {

      final locater = GetIt.instance;

      final userData = locater<UserDataProvider>();
      final storageData = locater<StorageDataProvider>();

      userData.setUsername(savedCustUsername);
      userData.setEmail(savedCustEmail);
      userData.setAccountType(savedAccountType);
      
      final accountType = await accountInformationRetriever.retrieveAccountType(email: savedCustEmail);
      userData.setAccountType(accountType);

      final dirListCount = await crud.countUserTableRow(GlobalsTable.directoryInfoTable);
      final dirLists = List.generate(dirListCount, (_) => GlobalsTable.directoryInfoTable);

      final tablesToCheck = [
        ...dirLists,
        GlobalsTable.homeImage, GlobalsTable.homeText, 
        GlobalsTable.homePdf, GlobalsTable.homeExcel, 
        GlobalsTable.homeVideo, GlobalsTable.homeAudio,
        GlobalsTable.homePtx, GlobalsTable.homeWord,
        GlobalsTable.homeExe, GlobalsTable.homeApk
      ];

      final futures = tablesToCheck.map((table) async {
        final fileNames = await nameGetterStartup.retrieveParams(conn, savedCustUsername, table);
        final bytes = await dataGetterStartup.getLeadingParams(conn, savedCustUsername, table);
        final dates = table == GlobalsTable.directoryInfoTable
            ? ["Directory"]
            : await dateGetterStartup.getDateParams(conn, savedCustUsername, table);
        return [fileNames, bytes, dates];
      }).toList();

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
      storageData.setFoldersName(uniqueFolders);
      storageData.setImageBytes(uniqueBytes);
      storageData.setFilesDate(dates);

    } catch (err) {
      NavigatePage.replacePageHome(context);
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
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SizedBox(
                height: 95,
                child: Image.asset(
                  'assets/images/SplashMain.png',
                ),
              ),
            ),
            const SizedBox(height: 265),
            Text(
              'Flowstorage',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 65),
          ],
        ),
      ),
    );
  }

}
import 'dart:convert';

import 'package:flowstorage_fsc/connection/cluster_fsc.dart';
import 'package:flowstorage_fsc/data_query/crud.dart';
import 'package:flowstorage_fsc/encryption/encryption_model.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/helper/special_file.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_button.dart';
import 'package:flowstorage_fsc/widgets/checkbox_item.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MoveFilePage extends StatefulWidget {

  final List<String> fileNames;
  final List<String> fileBase64Data;

  const MoveFilePage({
    required this.fileNames,
    required this.fileBase64Data,
    Key? key
  }) : super(key: key);

  @override
  State<MoveFilePage> createState() => MoveFilePageState();

}

class MoveFilePageState extends State<MoveFilePage> {

  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();

  final userData = GetIt.instance<UserDataProvider>();

  final encryption = EncryptionClass();
  final specialFile = SpecialFile();

  List<String> directoriesList = [];
  List<bool> checkedDirectory = [];

  String selectedDirectory = "";

  Widget buildBody() {
    return Column(
      children: [

        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 15.0, left: 16.0),
            child: Text("Select Directory",
              style: GoogleFonts.inter(
                color: ThemeColor.secondaryWhite,
                fontWeight: FontWeight.w800,
                fontSize: 19,
              ),
            ),
          ),
        ),

        directoriesList.isEmpty 
        ? buildOnEmpty()
        : SizedBox(
          height: 200,
          child: buildListView()
        ),

        const Spacer(),

        const Divider(color: ThemeColor.lightGrey),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.only(bottom: 25.0),
          child: MainButton(
            text: "Move", 
            onPressed: () async {
              if(selectedDirectory.isNotEmpty && !checkedDirectory.every((element) => false)) {
                await onMoveFile();
                
              } else {
                CustomAlertDialog.
                  alertDialog("Please select a directory.");
              }
            }
          ),
        ),

      ],
    );
  }

  Widget buildListView() {
    return RawScrollbar(
      child: ListView.builder(
        itemCount: directoriesList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () async {
              _updateCheckboxState(index, true);
            },
            child: Ink(
              color: ThemeColor.darkBlack,
              child: ListTile(
                leading: FutureBuilder(
                future: GetAssets().loadAssetsData('dir1.jpg'), 
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      height: 40,
                      width: 40,
                    );
                  } else {
                    return Container(
                      width: 25,
                      height: 25,
                      color: Colors.grey,
                    );
                  }
                },
              ),
              title: Text(
                directoriesList[index],
                style: GoogleFonts.inter(
                  color: ThemeColor.justWhite,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: CheckBoxItems(
                  index: index, 
                  updateCheckboxState: _updateCheckboxState,
                  checkedList: checkedDirectory
                ),            
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateCheckboxState(int index, bool value) {
    setState(() {
      checkedDirectory[index] = !checkedDirectory[index];
      if (checkedDirectory[index]) {
        for (int i = 0; i < checkedDirectory.length; i++) {
          if (i != index) {
            checkedDirectory[i] = false;
          }
        }
        selectedDirectory = directoriesList[index];

      } else {
        if (checkedDirectory.every((element) => !element)) {
          checkedDirectory = List.generate(checkedDirectory.length, (index) => false);
          selectedDirectory = "";
        }

      }
    });
  }

  Widget buildOnEmpty() {
    return Padding(
      padding: const EdgeInsets.only(top: 55.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            "No directory found",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              color: ThemeColor.secondaryWhite,
              fontSize: 21,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            "Add a new directory to move this file",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              color: ThemeColor.thirdWhite,
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
          ),
          
        ]
      ),
    );
  }

  Future<void> onMoveFile() async {

    final canMoveFile = await canMoveFileToDirectory();

    if(canMoveFile) {
      final loading = SingleTextLoading();

      if(mounted) {
        loading.startLoading(title: "Moving file(s)...", context: context);
      }

      await moveFileToDirectory();

      loading.stopLoading();

      SnackAlert.okSnack(message: "${widget.fileNames.length} File(s) has been moved to ${ShortenText().cutText(selectedDirectory)}.");

      await CallNotify().customNotification(title: "File Moved", subMessage: "${widget.fileNames.length} File(s) has been moved to ${ShortenText().cutText(selectedDirectory)}.");

    }

  }

  Future<void> moveFileToDirectory() async {
    
    final dateNow = DateFormat('dd/MM/yyyy').format(DateTime.now());
    
    final conn = await SqlConnection.initializeConnection();

    const query = "INSERT INTO upload_info_directory (CUST_USERNAME, CUST_FILE, DIR_NAME, CUST_FILE_PATH, UPLOAD_DATE, CUST_THUMB) VALUES (?, ?, ?, ?, ?, ?)";

    final encryptedDirectoryName = encryption.encrypt(selectedDirectory);

    final fileName = widget.fileNames;
    final fileData = widget.fileBase64Data;

    for(int i=0; i<widget.fileNames.length; i++) {
      
      final fileType = fileName[i].split('.').last;

      final encryptedData = specialFile.ignoreEncryption(fileType) 
        ? fileData[i] 
        : encryption.encrypt(fileData[i]);
        
      final encryptedFileName = encryption.encrypt(fileName[i]);

      if(Globals.videoType.contains(fileType)) {
        final thumbnailIndex = storageData.fileNamesFilteredList.indexOf(fileName[i]);
        final thumbnailBytes = storageData.imageBytesFilteredList.elementAt(thumbnailIndex);
        final thumbnail = base64.encode(thumbnailBytes!);
        await conn.prepare(query)
          ..execute([userData.username, encryptedData, encryptedDirectoryName, encryptedFileName, dateNow, thumbnail]);

      } else {
        await conn.prepare(query)
          ..execute([userData.username, encryptedData, encryptedDirectoryName, encryptedFileName, dateNow, null]);

      }

    }

  }

  Future<bool> canMoveFileToDirectory() async {

    const countFilesQuery = "SELECT COUNT(*) FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dir_name";
    final params = {
      'username': userData.username,
      'dir_name': encryption.encrypt(selectedDirectory)
    };

    final totalFiles = await Crud().count(
      query: countFilesQuery, params: params);

    if(totalFiles < AccountPlan.mapFilesUpload[userData.accountType]!) {

      bool hasDuplicatedFileName = false;

      const verifyFileName = "SELECT COUNT(CUST_FILE_PATH) FROM upload_info_directory WHERE CUST_USERNAME = :username AND DIR_NAME = :dir_name AND CUST_FILE_PATH = :file_name";

      for(final fileName in widget.fileNames) {

        final params = {
          'username': userData.username,
          'dir_name': encryption.encrypt(selectedDirectory),
          'file_name': encryption.encrypt(fileName)
        };

        final countDuplicatedFileName = await Crud().count(
          query: verifyFileName, params: params
        );

        if(countDuplicatedFileName >= 1) {
          hasDuplicatedFileName = true;
        }

      } 

      if(hasDuplicatedFileName) {
        CustomAlertDialog.alertDialogTitle("Failed to move this file", "Cannot move duplicated file");
        return false;

      } else {
        return true;

      }

    }

    return false;

  }

  void initializeDirectoriesName() {
    final getDirectory = tempStorageData.directoryNameList;
    directoriesList.addAll(getDirectory);
  }

  void initializeDirectoriesCheckbox() {
    final getDirectoryLength = tempStorageData.directoryNameList.length;
    checkedDirectory = List.generate(
      getDirectoryLength, (index) => false
    );
  }

  @override
  void initState() {
    super.initState();
    initializeDirectoriesName();
    initializeDirectoriesCheckbox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        context: context,
        title: widget.fileNames.length == 1 
          ? "Move ${ShortenText().cutText(widget.fileNames[0])}"
          : "Move ${widget.fileNames.length} item(s)",
      ).buildAppBar(),
      body: buildBody(),
    );
  }

}
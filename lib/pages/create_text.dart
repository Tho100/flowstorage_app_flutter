import 'dart:async';
import 'dart:convert';

import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/extra_query/insert_data.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/models/offline_mode.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/main_dialog_button.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class CreateText extends StatefulWidget {
  const CreateText({super.key});

  @override
  State<CreateText> createState() => CreateTextPageState();
}

class CreateTextPageState extends State<CreateText> {
  
  final userData = GetIt.instance<UserDataProvider>();
  final storageData = GetIt.instance<StorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  final textEditingController = TextEditingController();
  final fileNameController = TextEditingController();

  final logger = Logger();
  final getAssets = GetAssets();
  
  bool saveVisibility = true;
  bool textFormEnabled = true;

  Future<void> _insertUserFile({
    required String table,
    required String filePath,
    required dynamic fileValue,
  }) async {
    
    List<Future<void>> isolatedFileFutures = [];

    isolatedFileFutures.add(InsertData().insertValueParams(
      tableName: table,
      filePath: filePath,
      userName: userData.username,
      fileVal: fileValue,
    ));

    await Future.wait(isolatedFileFutures);

  }

  Future<bool> _isFileExists(String fileName) async {
    return storageData.fileNamesFilteredList.contains(fileName);
  }

  Future _buildSaveFileDialog() {
    return InteractDialog().buildDialog(
      context: context, 
      childrenWidgets: <Widget>[
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 8.0, left: 18.0, right: 18.0, top: 16.0),
              child: Text(
                "Save Text File",
                style: TextStyle(
                  color: ThemeColor.justWhite,
                  fontSize: 17,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        const Divider(color: ThemeColor.lightGrey),

        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 6.0, top: 6.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 1.0, color: ThemeColor.darkBlack),
            ),
            child: TextFormField(
              autofocus: true,
              style: const TextStyle(color: ThemeColor.justWhite),
              enabled: true,
              controller: fileNameController,
              decoration: GlobalsStyle.setupTextFieldDecoration("Untitled text file")
            ),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            const SizedBox(width: 5),

            MainDialogButton(
              text: "Cancel", 
              onPressed: () {
                fileNameController.clear();
                Navigator.pop(context);
              }, 
              isButtonClose: true
            ),
            
            const SizedBox(width: 10),
            
            MainDialogButton(
              text: "Save", 
              onPressed: () async {

                final getFileTitle = fileNameController.text.trim();
                if (getFileTitle.isEmpty) {
                  return;
                }
                
                await _saveText(textEditingController.text);

              }, 
              isButtonClose: false
            ),
            
            const SizedBox(width: 18),
          ],
        ),
        const SizedBox(height: 12),
      ]
    );
  }

  String _tableToUploadTo() {

    if(tempData.origin == OriginFile.home) {
      return GlobalsTable.homeText;

    } else if (tempData.origin == OriginFile.directory) {
      return GlobalsTable.directoryUploadTable;

    } else if (tempData.origin == OriginFile.folder) {
      return GlobalsTable.folderUploadTable;

    } else if (tempData.origin == OriginFile.public) {
      return GlobalsTable.psText;

    }

    return GlobalsTable.homeText;

  }

  void _addTextFileToListView({required String fileName}) async {

    final txtImageData = await getAssets.loadAssetsData('txt0.png');

    storageData.fileDateList.add("Just now");
    storageData.fileDateFilteredList.add("Just now");

    storageData.fileNamesList.add(fileName);
    storageData.fileNamesFilteredList.add(fileName);
    
    storageData.imageBytesList.add(txtImageData);
    storageData.imageBytesFilteredList.add(txtImageData);
    
  }

  Future<void> _saveText(String inputValue) async {

    final fileName = "${fileNameController.text.trim().replaceAll(".", "")}.txt";

    try {

      if (await _isFileExists(fileName)) {
        CustomAlertDialog.alertDialog("File with this name already exists.");
        return;
      }

      final toUtf8Bytes = utf8.encode(inputValue);
      final base64Encoded = base64.encode(toUtf8Bytes);

      if (tempData.origin == OriginFile.offline) {
        _createTextFileOnOffline(fileName, inputValue);
        return;

      } else {
        await _insertUserFile(
          table: _tableToUploadTo(),
          filePath: fileName,
          fileValue: base64Encoded,
        );
        
      }

      _updateUIAfterSave(fileName);

    } catch (err, st) {
      _createTextFileOnOffline(fileName, inputValue);
      logger.e("Exception from _saveText {create_text}", err, st);
    }
  }

  void _createTextFileOnOffline(String fileName, String inputValue) {
    OfflineMode().saveOfflineTextFile(
      inputValue: inputValue,
      fileName: fileName,
      isFromCreateTxt: true,
    );

    _updateUIAfterSave(fileName);
  }

  void _updateUIAfterSave(String fileName) async {

    _addTextFileToListView(fileName: fileName);

    setState(() {
      saveVisibility = false;
      textFormEnabled = false;
    });


    await CallNotify().customNotification(
      title: "Text File Saved",
      subMesssage: ShortenText().cutText("$fileName Has been saved"),
    );

    if (!mounted) return;

    SnakeAlert.okSnake(
      message: "`${fileNameController.text.replaceAll(".txt", "")}.txt` Has been saved${tempData.origin == OriginFile.offline ? " as an offline file." : "."}",
      icon: Icons.check,
    );

    fileNameController.clear();
    Navigator.pop(context);
  }

  Widget _buildTxt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        autofocus: true,
        controller: textEditingController,
        enabled: textFormEnabled,
        keyboardType: TextInputType.multiline,
          maxLines: null,
          style: GoogleFonts.roboto(
            color: const Color.fromARGB(255, 214, 213, 213),
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
            ),
          ),
      ),
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColor.darkBlack,
      appBar: AppBar(
        actions: [

          Visibility(
            visible: saveVisibility,
            child: TextButton(
              onPressed: () {
                _buildSaveFileDialog();
              },
              child: const Text("Save",
                style: TextStyle(
                  color: ThemeColor.darkPurple,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        backgroundColor: ThemeColor.darkBlack,
        elevation: 0,
        title: const Text("New Text File",
          style: GlobalsStyle.appBarTextStyle
        ),
      ),
      body: _buildTxt(context),
    );
  }
}
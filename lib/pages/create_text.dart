import 'dart:async';
import 'dart:convert';

import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/interact_dialog/text_dialog/discard_changes_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/text_dialog/save_text_dialog.dart';
import 'package:flowstorage_fsc/models/update_list_view.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/data_query/insert_data.dart';
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

    try {
    
      List<Future<void>> isolatedFileFutures = [];

      isolatedFileFutures.add(InsertData().insertValueParams(
        tableName: table,
        fileName: filePath,
        userName: userData.username,
        fileValue: fileValue,
        videoThumbnail: null
      ));

      await Future.wait(isolatedFileFutures);

    } catch (err) {
      _createTextFileOnOffline(filePath, fileValue);
    }

  }

  bool _isFileExists(String fileName) {
    return storageData.fileNamesFilteredList.contains(fileName);
  }

  String _tableToUploadTo() {

    switch (tempData.origin) {
      case OriginFile.home:
        return GlobalsTable.homeText;

      case OriginFile.directory:
        return GlobalsTable.directoryUploadTable;

      case OriginFile.folder:
        return GlobalsTable.folderUploadTable;

      case OriginFile.public:
        return GlobalsTable.psText;

      default:
        return GlobalsTable.homeText;
    }

  }

  void _addTextFileToListView({required String fileName}) async {

    final txtImageData = await getAssets.loadAssetsData('txt0.jpg');

    UpdateListView().addItemDetailsToListView(fileName: fileName);

    storageData.imageBytesList.add(txtImageData);
    storageData.imageBytesFilteredList.add(txtImageData);
    
  }

  Future<void> _saveText(String inputValue) async {

    final fileName = "${fileNameController.text.trim().replaceAll(".", "")}.txt";

    try {

      if (_isFileExists(fileName)) {
        CustomAlertDialog.alertDialog("File with this name already exists.");
        return;
      }

      final toUtf8Bytes = utf8.encode(inputValue);
      final base64Encoded = base64.encode(toUtf8Bytes);
      final base64Bytes = base64.decode(base64Encoded);

      final compressedFileBytes = CompressorApi.compressByte(base64Bytes);
      final compressedFileBase64 = base64.encode(compressedFileBytes);
      
      if (tempData.origin == OriginFile.offline) {
        _createTextFileOnOffline(fileName, compressedFileBase64);
        return;

      } else {
        await _insertUserFile(
          table: _tableToUploadTo(),
          filePath: fileName,
          fileValue: compressedFileBase64,
        );
        
      }

      _updateUIAfterSave(fileName);

    } catch (err, st) {
      logger.e("Exception from _saveText {create_text}", err, st);

    }
    
  }

  void _createTextFileOnOffline(String fileName, String inputValue) {
    
    OfflineMode().saveOfflineTextFile(
      inputValue: inputValue,
      fileName: fileName,
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
      subMesssage: "${ShortenText().cutText(fileName)} Has been saved",
    );

    SnakeAlert.okSnake(
      message: "`${fileNameController.text.replaceAll(".txt", "")}.txt` Has been saved${tempData.origin == OriginFile.offline ? " as an offline file." : "."}",
      icon: Icons.check,
    );

    fileNameController.clear();

    if(!mounted) return;
    Navigator.pop(context);
    
  }

  Widget _buildTxt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 16.0, right: 16, left: 16),
      child: TextFormField(
        autofocus: true,
        controller: textEditingController,
        enabled: textFormEnabled,
        keyboardType: TextInputType.multiline,
          maxLines: 140,
          maxLength: 3100,
          style: GoogleFonts.roboto(
            color: const Color.fromARGB(255, 220, 220, 220),
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(
            counterStyle: TextStyle(color: ThemeColor.secondaryWhite),
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

  Future<bool> discardChangesConfirmation() async {
    bool confirm = await DiscardChangesDialog()
                      .buildConfirmationDialog(context);
    return confirm;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        
        if(saveVisibility == true) {
          return await discardChangesConfirmation();
        } else {
          return true;
        }
        
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
    
            Visibility(
              visible: saveVisibility,
              child: TextButton(
                onPressed: () {
                  SaveTextDialog().buildSaveTextDialog(
                    fileNameController: fileNameController, 
                    saveOnPressed: () async {
                      final getFileTitle = fileNameController.text.trim();
                      if (getFileTitle.isEmpty) {
                        return;
                      }
                      
                      await _saveText(textEditingController.text);
                    }, 
                    context: context
                  );
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
      ),
    );
  }
}
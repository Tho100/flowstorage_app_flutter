import 'dart:async';
import 'dart:convert';

import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/global_table.dart';
import 'package:flowstorage_fsc/interact_dialog/text_dialog/discard_changes_dialog.dart';
import 'package:flowstorage_fsc/interact_dialog/text_dialog/save_text_dialog.dart';
import 'package:flowstorage_fsc/models/update_list_view.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/data_query/insert_data.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/get_assets.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/models/offline_model.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/buttons/right_text_button.dart';
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
  final tempStorageData = GetIt.instance<TempStorageProvider>();

  final textEditingController = TextEditingController();
  final fileNameController = TextEditingController();

  final logger = Logger();
  final getAssets = GetAssets();
  
  final saveVisibilityNotifier = ValueNotifier<bool>(true);
  final textFormEnabledNotifier = ValueNotifier<bool>(true);

  Future<void> _insertTextFile({
    required String table,
    required String fileName,
    required String fileValue,
  }) async {

    try {
    
      await InsertData().insert(
        tableName: table,
        fileName: fileName,
        userName: userData.username,
        fileValue: fileValue,
        videoThumbnail: null
      );

      _updateUIAfterSave(fileName, false);

    } catch (err) {
      _createTextFileOnOffline(fileName, fileValue);
      return;
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
        await _insertTextFile(
          table: _tableToUploadTo(),
          fileName: fileName,
          fileValue: compressedFileBase64,
        );
        
      } 

    } catch (err, st) {
      logger.e("Exception from _saveText {create_text}", err, st);

    }
    
  }

  void _createTextFileOnOffline(String fileName, String inputValue) {
    
    OfflineModel().saveOfflineTextFile(
      inputValue: inputValue,
      fileName: fileName,
    );

    tempStorageData.addOfflineFileName(fileName);

    _updateUIAfterSave(fileName, true);

  }

  void _updateUIAfterSave(String fileName, bool isFromOffline) async {

    _addTextFileToListView(fileName: fileName);

    saveVisibilityNotifier.value = false;
    textFormEnabledNotifier.value = false;

    await CallNotify().customNotification(
      title: "Text File Saved",
      subMessage: "${ShortenText().cutText(fileName)} Has been saved",
    );

    SnackAlert.okSnack(
      message: "'${fileNameController.text.replaceAll(".txt", "")}.txt' Has been saved${isFromOffline ? " as an offline file." : "."}",
      icon: Icons.check,
    );

    fileNameController.clear();

    if(mounted) {
      Navigator.pop(context);
    }
    
  }

  Widget _buildTextBody() {
    return Padding(
      padding: const EdgeInsets.only(top: 6.0, bottom: 16.0, right: 16, left: 16),
      child: ValueListenableBuilder(
        valueListenable: textFormEnabledNotifier,
        builder: (context, value, child) {
          return TextFormField(
            autofocus: true,
            controller: textEditingController,
            enabled: value,
            keyboardType: TextInputType.multiline,
            maxLines: 500,
            maxLength: 5500,
            style: GoogleFonts.inter(
              color: const Color.fromARGB(255, 220, 220, 220),
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
              ),
              counterText: '',
            ),
          );
        },
      ),
    );
  }

  Future<bool> _discardChangesConfirmation() async {
    return await DiscardChangesDialog()
                      .buildConfirmationDialog(context);
  }

  Future<bool> _onPageClose() async {

    final isAskForSave = textEditingController.text.isNotEmpty 
      && saveVisibilityNotifier.value == true;

    if(isAskForSave) {
      return await _discardChangesConfirmation();
    } 
    
    return true;

  }

  @override
  void dispose() {
    saveVisibilityNotifier.dispose();
    textFormEnabledNotifier.dispose();
    textEditingController.dispose();
    fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _onPageClose(),
      child: Scaffold(
        appBar: CustomAppBar(
          customBackOnPressed: () async {
            final closePage = await _onPageClose();
            if(closePage) {
              Navigator.pop(context);
            }
          },
          context: context,
          title: "New Text File",
          actions: [
            ValueListenableBuilder(
              valueListenable: saveVisibilityNotifier,
              builder: (context, value, child) {
                return Visibility(
                  visible: value,
                  child: RightTextButton(
                    text: "Save",
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
                    }
                  ),
                );
              },
            ),
          ]
        ).buildAppBar(),
        body: _buildTextBody(),
      ),
    );
  }

}
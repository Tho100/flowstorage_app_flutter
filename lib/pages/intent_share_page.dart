import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/call_notification.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/interact_dialog/bottom_trailing/upgrade_dialog.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/models/offline_model.dart';
import 'package:flowstorage_fsc/models/upload_dialog.dart';
import 'package:flowstorage_fsc/previewer/preview_pdf.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/form_dialog.dart';
import 'package:flowstorage_fsc/user_settings/account_plan_config.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// ignore: must_be_immutable
class IntentSharingPage extends StatelessWidget {

  final String fileName;
  final String filePath;
  final String fileData;
  final String? imageBase64Encoded;

  IntentSharingPage({
    required this.fileName,
    required this.filePath,
    required this.fileData,
    required this.imageBase64Encoded,
    Key? key
  }) : super(key: key);

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final userData = GetIt.instance<UserDataProvider>();

  String fileType = "";

  Widget buildBody(BuildContext context) {

    fileType = fileName.split('.').last;

    return Column(
      children: [

        const SizedBox(height: 5),

        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [

              Stack(
                children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      base64.decode(imageBase64Encoded!),
                      width: 105,
                      height: 105,
                      fit: Globals.generalFileTypes.contains(fileType) 
                        ? BoxFit.scaleDown : BoxFit.fitWidth,
                    )
                  ),
                ),

                if(Globals.videoType.contains(fileType))
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ThemeColor.mediumGrey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 20)
                    ),
                ), 
                ],
              ),

              const SizedBox(width: 10),

              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ShortenText().cutText(fileName),
                    style: const TextStyle(
                      color: ThemeColor.secondaryWhite,
                      fontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${fileSizeInMb()}Mb",
                    style: const TextStyle(
                      color: ThemeColor.secondaryWhite,
                      fontSize: 13,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),  

        if(fileType == "pdf")
        Padding(
          padding: const EdgeInsets.only(right: 15.0, bottom: 8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 138,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(52),
                    side: const BorderSide(color: ThemeColor.lightGrey)
                  ),
                  backgroundColor: ThemeColor.darkBlack,
                ),
                onPressed: () {
                  previewPdfOnPressed(context);
                },
                child: const Text("Preview"),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
        const Divider(color: ThemeColor.lightGrey, height: 2),

      ],
    );
  }

  String fileSizeInMb() {

    final fileByte = base64.decode(fileData);
    double getSizeMB = fileByte.lengthInBytes/(1024*1024);
    
    return getSizeMB.toDouble().toStringAsFixed(2);
    
  }

  void previewPdfOnPressed(BuildContext context) {

    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PreviewPdf(
        isFromIntentSharing: true, 
        customFileDataBase64: fileData
        )
      )
    );

  }

  Future<void> processFileUpload(BuildContext context) async {

    try {

      if(tempData.origin == OriginFile.offline && Globals.videoType.contains(fileType)) {
        CustomFormDialog.startDialog("Upload Failed", "Video is not available for offline.");
        return;
      }

      await UploadDialog(
        upgradeExceededDialog: exceededUploadDialog
      ).intentShareUpload(fileName: fileName, filePath: filePath);

      Navigator.pop(context);

    } catch (err) {
      NotificationApi.stopNotification(0);
      saveFileAsOffline();
    }

  }

  void saveFileAsOffline() async {

    if(tempStorageData.offlineFileNameList.contains(fileName)) {
      CustomFormDialog.startDialog("Upload Failed", "$fileName already exists.");
      return;
    }

    if(Globals.videoType.contains(fileType)) {
      CustomFormDialog.startDialog("Upload Failed", "Video is not available for offline.");
      return;
    }

    Uint8List fileBytes = Uint8List(0);

    if(Globals.imageType.contains(fileType)) {
      fileBytes = base64.decode(fileData);

    } else {
      fileBytes = CompressorApi.compressByte(base64.decode(fileData));

    }

    await OfflineModel().processSaveOfflineFile(
      fileName: fileName, 
      fileData: fileBytes
    );

    tempStorageData.addOfflineFileName(fileName);

    await CallNotify().customNotification(title: "Offline", subMesssage: "1 Item now available offline");

  }

  Future exceededUploadDialog() {
    return UpgradeDialog.buildUpgradeBottomSheet(
      message: "It looks like you're exceeding the number of files you can upload. Upgrade your account to upload more.",
      context: navigatorKey.currentContext!
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        automaticallyImplyLeading: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              child: const Text("Upload",
                  style: TextStyle(
                  color: ThemeColor.darkPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () async {
                    
                if (storageData.fileNamesList.contains(fileName)) {
                  CustomFormDialog.startDialog("Upload Failed", "$fileName already exists.");
                  return;
          
                }
          
                if(!Globals.supportedFileTypes.contains(fileType)) {
                  CustomFormDialog.startDialog("Couldn't upload $fileName","File type is not supported.");
                  return;
          
                }
          
                final allowedFileUploads = AccountPlan.mapFilesUpload[userData.accountType]!;
          
                if (storageData.fileNamesList.length + 1 > allowedFileUploads) {
                  return exceededUploadDialog();
                  
                }
          
                await processFileUpload(context);
          
              }
            ),
          ),
        ],
        title: const Text("Upload to Flowstorage", 
          style: GlobalsStyle.appBarTextStyle
        ),
      ),
      body: buildBody(context),
    );
  }
}
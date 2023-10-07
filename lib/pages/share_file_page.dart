import 'dart:io';
import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/extra_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/process_file_sharing.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareFilePage extends StatelessWidget {

  final String fileName;

  ShareFilePage({
    required this.fileName,
    Key? key
  }) : super(key: key);

  final shareToController = TextEditingController();
  final commentController = TextEditingController();

  final storageData = GetIt.instance<StorageDataProvider>();

  Widget buildBody(BuildContext context) {

    return Column(
      children: [

        const SizedBox(height: 5),

        Row(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image(
                      width: 55,
                      height: 55,
                      fit: BoxFit.cover, 
                      image: MemoryImage(storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexWhere((name) => name == fileName)]!),
                    ),
                  ),
                ),

                if(Globals.videoType.contains(fileName.split('.').last))
                Padding(
                  padding: const EdgeInsets.only(top: 22.0, left: 24.0),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ThemeColor.mediumGrey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 22)
                  ),
                ),
              ],
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    ShortenText().cutText(fileName, customLength: 42),
                    style: const TextStyle(
                      color: ThemeColor.justWhite,
                      fontSize: 15,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            
          ],
        ),
        const SizedBox(height: 5),

        const Divider(color: ThemeColor.lightGrey, height: 2),

        Padding(
          padding: const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 10, top: 15),
          child: TextFormField(
            style: const TextStyle(color: ThemeColor.secondaryWhite),
            enabled: true,
            controller: shareToController,
            decoration: GlobalsStyle.setupTextFieldDecoration("Enter receiver username"),
          ),
        ),
         
        Padding(
          padding: const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 15, top: 0),
            child:TextFormField(
              style: const TextStyle(color: ThemeColor.secondaryWhite),
              enabled: true,
              controller: commentController,
              maxLines: 15,
              maxLength: 100,
              decoration: GlobalsStyle.setupTextFieldDecoration("Enter a comment"),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(right: 16.0, top: 6.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 58,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(52),
                    side: const BorderSide(color: ThemeColor.lightGrey)
                  ),
                  backgroundColor: ThemeColor.darkGrey,
                ),
                onPressed: () {
                  shareExternalOnPressed();
                },
                child: const Icon(Icons.share),
              ),
            ),
          ),
        ),

      ],
    );
  }

  Widget buildBackIconButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
        onClosePressed();
        Navigator.pop(context);
      },
    );
  }

  void shareExternalOnPressed() async {

    final userData = GetIt.instance<UserDataProvider>();
    final tempData = GetIt.instance<TempDataProvider>();

    final retrieveData = RetrieveData();
    final loadingDialog = SingleTextLoading();

    try {

      late Uint8List fileBytes = Uint8List(0);

      final fileType = fileName.split('.').last;

      if (Globals.imageType.contains(fileType)) {
        final index = storageData.fileNamesFilteredList.indexOf(fileName);
        if (index >= 0) {
          fileBytes = storageData.imageBytesFilteredList[index]!;
        }

      } else {
        loadingDialog.startLoading(title: "Fetching data...", context: navigatorKey.currentContext!);

        final tableName = tempData.origin == OriginFile.public
            ? Globals.fileTypesToTableNamesPs[fileType]!
            : Globals.fileTypesToTableNames[fileType]!;

        fileBytes = await retrieveData.retrieveDataParams(
            userData.username, fileName, tableName);

        loadingDialog.stopLoading();

      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(fileBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: commentController.text 
      ); 

      await file.delete();

    } catch (err) {
      SnakeAlert.errorSnake("Failed to start sharing.");
    }

  }
  
  void onClosePressed() {
    shareToController.clear();
    commentController.clear();
  }

  void processFileSharing(String fileName, BuildContext context) {
    final shareToInput = shareToController.text;
    final comment = commentController.text;

    ProcessFileSharing().shareOnPressed(
      receiverUsername: shareToInput,
      fileName: fileName,
      commentInput: comment,
      context: context
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        automaticallyImplyLeading: false,
        leading: buildBackIconButton(context),
        actions: [
          TextButton(
            child: const Text("Share",
                style: TextStyle(
                color: ThemeColor.darkPurple,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              processFileSharing(fileName, context);
            }
          ),
        ],
        title: const Text("Share File", 
          style: GlobalsStyle.appBarTextStyle
        ),
      ),
      body: buildBody(context),
    );
  }

}
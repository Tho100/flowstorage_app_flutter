import 'dart:io';
import 'dart:typed_data';

import 'package:flowstorage_fsc/api/compressor_api.dart';
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/data_query/retrieve_data.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/user_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/process_file_sharing.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/ui_dialog/loading/single_text_loading.dart';
import 'package:flowstorage_fsc/ui_dialog/snack_dialog.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/buttons/right_text_button.dart';
import 'package:flowstorage_fsc/widgets/text_field/main_text_field.dart';
import 'package:flowstorage_fsc/widgets/video_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
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

    final fileType = fileName.split('.').last;

    final isGeneralFile = Globals.generalFileTypes.contains(fileType);

    return Column(
      children: [

        const SizedBox(height: 5),

        Row(
          children: [
            Stack(
              children: [

                Padding(
                  padding: const EdgeInsets.only(left: 18, top: 12, bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image(
                      width: isGeneralFile ? 38 : 55,
                      height: isGeneralFile ? 38 : 55,
                      fit: BoxFit.cover, 
                      image: MemoryImage(storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexWhere((name) => name == fileName)]!),
                    ),
                  ),
                ),

                if(Globals.videoType.contains(fileName.split('.').last))
                const Padding(
                  padding: EdgeInsets.only(top: 22.0, left: 28.0),
                  child: VideoPlaceholderWidget(),
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
                    style: GoogleFonts.inter(
                      color: ThemeColor.secondaryWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
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
          child: MainTextField(
            hintText: "Enter receiver username",
            controller: shareToController,
          ),
        ),
         
        Padding(
          padding: const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 15),
          child: MainTextField(
            hintText: "Enter a comment (Optional)",
            maxLines: 12,
            maxLength: 100,
            controller: commentController,
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 145,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(52),
                    side: const BorderSide(color: ThemeColor.lightGrey)
                  ),
                  backgroundColor: ThemeColor.darkBlack,
                ),
                onPressed: () => shareExternalOnPressed(),
                child: Row(
                  children: [
                    const Icon(Icons.share),
                    const SizedBox(width: 8),
                    Text("Apps Share",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

      ],
    );
    
  }

  void shareExternalOnPressed() async {

    final userData = GetIt.instance<UserDataProvider>();
    final tempData = GetIt.instance<TempDataProvider>();

    final retrieveData = RetrieveData();
    final loadingDialog = SingleTextLoading();

    Uint8List fileBytes = Uint8List(0);

    try {

      if(fileBytes.isEmpty) {

        final fileType = fileName.split('.').last;

        if (Globals.imageType.contains(fileType)) {
          final index = storageData.fileNamesFilteredList.indexOf(fileName);
          if (index >= 0) {
            fileBytes = storageData.imageBytesFilteredList[index]!;
          }

        } else {

          loadingDialog.startLoading(title: "Fetching data...", context: navigatorKey.currentContext!);

          final tableName = tempData.origin == OriginFile.public && tempData.origin == OriginFile.publicSearching
            ? Globals.fileTypesToTableNamesPs[fileType]!
            : Globals.fileTypesToTableNames[fileType]!;

          if(tempData.fileByteData.isEmpty) {
            fileBytes = await retrieveData.getFileData(
              userData.username, fileName, tableName);

          } else {
            fileBytes = CompressorApi.compressByte(tempData.fileByteData);

          }

          loadingDialog.stopLoading();

        }

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
      SnackAlert.errorSnack("Failed to start sharing.");
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
      appBar: CustomAppBar(
        context: context, 
        title: "Share File",
        actions: [
          RightTextButton(
            text: "Share",
            onPressed: () => processFileSharing(fileName, context),
          ),
        ],
      ).buildAppBar(),
      body: buildBody(context),
    );
  }

}
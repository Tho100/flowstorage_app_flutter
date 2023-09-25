
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/sharing_query/process_file_sharing.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/main_dialog_button.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SharingDialog {

  final shareToController = TextEditingController();
  final commentController = TextEditingController();
  final storageData = GetIt.instance<StorageDataProvider>();

  Future buildSharingDialog({
    String? fileName,
    BuildContext? context
  }) {
    return InteractDialog().buildDialog(
      context: context!, 
      childrenWidgets: <Widget>[
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

                if(Globals.videoType.contains(fileName!.split('.').last))
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
                padding: const EdgeInsets.only(left: 8.0),
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

        const Divider(color: ThemeColor.lightGrey),

        const SizedBox(height: 5),

        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 18.0),
              child: Text(
                "Share this file",
                style: TextStyle(
                  color: ThemeColor.secondaryWhite,
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 10, top: 15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(width: 1.0, color: ThemeColor.darkBlack),
            ),
            child: TextFormField(
              style: const TextStyle(color: ThemeColor.secondaryWhite),
              enabled: true,
              controller: shareToController,
              decoration: GlobalsStyle.setupTextFieldDecoration("Enter receiver username"),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(right: 15.0, left: 15.0, bottom: 15, top: 0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(width: 1.0, color: ThemeColor.darkBlack),
              ),
              child: TextFormField(
                style: const TextStyle(color: ThemeColor.secondaryWhite),
                enabled: true,
                controller: commentController,
                maxLines: 4,
                decoration: GlobalsStyle.setupTextFieldDecoration("Enter a comment"),
              ),
            
          ),
        ),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            const SizedBox(width: 5),

            MainDialogButton(
              text: "Close",
              onPressed: () {
                shareToController.clear();
                commentController.clear();
                Navigator.pop(context);
              },
              isButtonClose: true,
            ),
            
            const SizedBox(width: 10),

            MainDialogButton(
              text: "Share",
              onPressed: () {
                processFileSharing(fileName, context);
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

}
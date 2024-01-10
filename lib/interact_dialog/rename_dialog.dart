import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class RenameDialog {

  final storageData = GetIt.instance<StorageDataProvider>();

  static final renameController = TextEditingController();
  
  Future buildRenameFileDialog({
    required String fileName,
    required VoidCallback onRenamePressed,
    required BuildContext context
  }) async {

    final fileType = fileName.split('.').last;

    final lastDotIndex = fileName.lastIndexOf('.');
    final fileNameWithoutExtension = lastDotIndex != -1
      ? fileName.substring(0, lastDotIndex)
      : fileName;
      
    renameController.text = fileNameWithoutExtension;

    return InteractDialog().buildDialog(
      context: context, 
      childrenWidgets: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Stack(
              children: [
                
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image(
                      width: Globals.generalFileTypes.contains(fileType) 
                        ? 36 : 55,
                      height: Globals.generalFileTypes.contains(fileType) 
                        ? 36 : 55,
                      fit: BoxFit.cover,
                      image: MemoryImage(storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexWhere((name) => name == fileName)]!),
                    ),
                  ),
                ),

                if(Globals.videoType.contains(fileType))
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
                child: Text(
                  ShortenText().cutText(fileName),
                  style: const TextStyle(
                    color: ThemeColor.justWhite,
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            IconButton(
              onPressed: () {
                copyOnPressed(fileName);
              },
              icon: const Icon(Icons.copy,color: ThemeColor.thirdWhite,size: 22),
            ),

          ],
        ),

        const Divider(color: ThemeColor.whiteGrey),

        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 6.0, top: 6.0),
          child: TextFormField(
            autofocus: true,
            style: const TextStyle(color: ThemeColor.secondaryWhite),
            enabled: true,
            controller: renameController,
            decoration: GlobalsStyle.setupTextFieldDecoration("Enter new name"),
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
                renameController.clear();
                Navigator.pop(context);
              }, 
              isButtonClose: true
            ),

            const SizedBox(width: 10),

            MainDialogButton(
              text: "Rename", 
              onPressed: () {
                onRenamePressed();
                renameController.clear();
                Navigator.pop(context);
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

  void copyOnPressed(String fileName) {
    final removedFileType = fileName
      .substring(0, fileName.lastIndexOf('.'));

    Clipboard.setData(ClipboardData(text: removedFileType));
    CallToast.call(message: "Copied to clipboard.");
  }

}
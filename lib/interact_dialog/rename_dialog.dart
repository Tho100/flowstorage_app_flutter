import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/call_toast.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/buttons/main_dialog_button.dart';
import 'package:flowstorage_fsc/widgets/video_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class RenameDialog {

  final storageData = GetIt.instance<StorageDataProvider>();

  static final renameController = TextEditingController();
  
  void copyOnPressed(String fileName) {

    final removedFileType = fileName
      .substring(0, fileName.lastIndexOf('.'));

    Clipboard.setData(ClipboardData(text: removedFileType));
    CallToast.call(message: "Copied to clipboard.");

  }

  Future buildRenameFileDialog({
    required String fileName,
    required VoidCallback onRenamePressed,
  }) async {

    final fileType = fileName.split('.').last;

    final lastDotIndex = fileName.lastIndexOf('.');
    final fileNameWithoutExtension = lastDotIndex != -1
      ? fileName.substring(0, lastDotIndex)
      : fileName;

    final isGeneralFile = Globals.generalFileTypes.contains(fileType);

    renameController.text = fileNameWithoutExtension;

    return InteractDialog().buildDialog(
      context: navigatorKey.currentContext!,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Stack(
              children: [
                
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
                  child: GestureDetector(
                    onTap: () => NavigatePage.goToPagePongGame(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image(
                        width: isGeneralFile ? 36 : 55,
                        height: isGeneralFile ? 36 : 55,
                        fit: BoxFit.cover,
                        image: MemoryImage(storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexWhere((name) => name == fileName)]!),
                      ),
                    ),
                  ),
                ),

                if(Globals.videoType.contains(fileType))
                const Padding(
                  padding: EdgeInsets.only(top: 22.0, left: 24.0),
                  child: VideoPlaceholderWidget(),
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
              onPressed: () => copyOnPressed(fileName),
              icon: const Icon(Icons.copy, 
                color: ThemeColor.thirdWhite, size: 22
              ),
            ),

          ],
        ),

        const Divider(color: ThemeColor.lightGrey),

        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 6.0, top: 6.0),
          child: TextFormField(
            autofocus: true,
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w500,
            ),
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
                Navigator.pop(navigatorKey.currentContext!);
              }, 
              isButtonClose: true
            ),

            const SizedBox(width: 10),

            MainDialogButton(
              text: "Rename", 
              onPressed: () {
                onRenamePressed();
                renameController.clear();
                Navigator.pop(navigatorKey.currentContext!);
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

}
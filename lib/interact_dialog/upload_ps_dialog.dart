import 'dart:convert';

import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/ps_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/interact_dialog.dart';
import 'package:flowstorage_fsc/widgets/main_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PsCommentDialog {

  static final commentController = TextEditingController();
  static final titleController = TextEditingController();
  
  static const tagsItems = {
    "Entertainment",
    "Random",
    "Creativity",
    "Data",
    "Gaming",
    "Software",
    "Education",
    "Music",
  };

  final  selectedTagValue = ValueNotifier<String>('');
  final psUploadData = GetIt.instance<PsUploadDataProvider>();

  Future buildPsCommentDialog({
    required String fileName,
    required VoidCallback onUploadPressed,
    required BuildContext context,
    String? imageBase64Encoded
  }) async {
    return InteractDialog().buildDialog(
      context: context, 
      childrenWidgets: <Widget>[
        const Padding(
          padding: EdgeInsets.only(left: 14, top: 16),
          child: Text(
            "Public Storage",
            style: TextStyle(
              color: ThemeColor.justWhite,
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.only(left: 16, top: 4),
          child: Row(
            children: [

              if(Globals.imageType.contains(fileName.split('.').last) || Globals.videoType.contains(fileName.split('.').last))
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.memory(
                    base64.decode(imageBase64Encoded!),
                    fit: BoxFit.fitWidth,
                  )
                ),
              ),

              if(Globals.imageType.contains(fileName.split('.').last) || Globals.videoType.contains(fileName.split('.').last))
              const SizedBox(width: 10),

              Text(
                ShortenText().cutText(fileName),
                style: const TextStyle(
                  color: ThemeColor.secondaryWhite,
                  fontSize: 15,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 5),

        const Divider(color: ThemeColor.lightGrey),

        const SizedBox(height: 5),
          
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 2.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(width: 1.0, color: ThemeColor.darkGrey),
            ),
            child: TextFormField(
              style: const TextStyle(color: ThemeColor.secondaryWhite),
              enabled: true,
              controller: titleController,
              maxLines: 1,
              maxLength: 25,
              decoration: GlobalsStyle.setupTextFieldDecoration("Enter a title (Optional)"),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(width: 1.0, color: ThemeColor.darkGrey),
            ),
            child: TextFormField(
              style: const TextStyle(color: ThemeColor.secondaryWhite),
              enabled: true,
              controller: commentController,
              maxLines: 5,
              maxLength: 250,
              decoration: GlobalsStyle.setupTextFieldDecoration("Enter a comment (Optional)"),
            ),
          ),
        ),

        const SizedBox(height: 5),

        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 14.0),
              child: Text(
                "Tags", 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: ValueListenableBuilder<String>(
                valueListenable: selectedTagValue,
                builder: (context, value, child) {
                  return Visibility(
                    visible: value != "",
                    child: Text(
                      "${GlobalsStyle.dotSeperator} $value",
                      style: TextStyle(
                        color: GlobalsStyle.psTagsToColor[value],
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
              ),
            ),
          ],
        ),
        
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: ThemeColor.darkGrey,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8, left: 2, right: 2),
              child: SizedBox(
                height: 55,
                child: ListView.builder(
                  itemCount: tagsItems.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Container(
                    height: 45,
                    width: 122,
                    margin: const EdgeInsets.all(8),
                    color: Colors.transparent,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)
                        ),
                        backgroundColor: GlobalsStyle.psTagsToColor[tagsItems.elementAt(index)]
                      ),
                      onPressed: () {
                        psUploadData.setTagValue(tagsItems.elementAt(index));
                        selectedTagValue.value = psUploadData.psTagValue;
                      },
                      child: Text(tagsItems.elementAt(index)),
                    )
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 5),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            const SizedBox(width: 5),

            MainDialogButton(
              text: "Cancel", 
              onPressed: () {
                clearValues();
                Navigator.pop(context);
                return;
              }, 
              isButtonClose: true
            ),

            const SizedBox(width: 10),

            MainDialogButton(
              text: "Upload", 
              onPressed: () {

                titleController.text.isEmpty 
                  ? psUploadData.setTitleValue("Untitled")
                  : psUploadData.setTitleValue(titleController.text);

                psUploadData.setCommentValue(commentController.text);
                onUploadPressed();

                clearController();

                Navigator.pop(context);
              }, 
              isButtonClose: false
            ),

            const SizedBox(width: 18),
          ],
        ),

        const SizedBox(height: 12),

      ],
    );

  }

  void clearValues() async {
    await NotificationApi.stopNotification(0);
    psUploadData.setCommentValue('');
    psUploadData.setTagValue('');
    psUploadData.setTitleValue('');
    commentController.clear();
    titleController.clear();
  }

  void clearController() {
    titleController.clear();
    commentController.clear();
  }

}
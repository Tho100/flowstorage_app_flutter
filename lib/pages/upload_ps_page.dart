import 'dart:convert';

import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/ps_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UploadPsPage extends StatelessWidget {

  final String fileName;
  final String fileBase64Encoded;
  final VoidCallback onUploadPressed;
  final String? imageBase64Encoded;

  UploadPsPage({
    required this.fileName,
    required this.onUploadPressed,
    required this.imageBase64Encoded,
    required this.fileBase64Encoded,
    Key? key
  }) : super(key: key);

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

  final selectedTagValue = ValueNotifier<String>('');
  final psUploadData = GetIt.instance<PsUploadDataProvider>();

  String fileSizeInMb() {

    final fileByte = base64.decode(fileBase64Encoded);

    double getSizeMB = fileByte.lengthInBytes/(1024*1024);
    return getSizeMB.toDouble().toStringAsFixed(2);
    
  }

  Widget buildBody(BuildContext context) {

    final mediaQuery = MediaQuery.of(context).size;

    return Column(
      children: [

        const SizedBox(height: 5),

        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [

              if(Globals.imageType.contains(fileName.split('.').last) || Globals.videoType.contains(fileName.split('.').last))
              Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 75,
                    height: 75,
                    child: Image.memory(
                      base64.decode(imageBase64Encoded!),
                      fit: BoxFit.fitWidth,
                    )
                  ),
                ),
              ),

              const SizedBox(width: 8),

              if(Globals.generalFileTypes.contains(fileName.split('.').last))
              const SizedBox(width: 18),

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

        const SizedBox(height: 5),

        const Divider(color: ThemeColor.lightGrey),

        const SizedBox(height: 5),

        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 2.0),
          child: TextFormField(
            style: const TextStyle(color: ThemeColor.secondaryWhite),
            enabled: true,
            controller: titleController,
            maxLines: 1,
            maxLength: 25,
            decoration: GlobalsStyle.setupTextFieldDecoration("Enter a title (Optional)"),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextFormField(
            style: const TextStyle(color: ThemeColor.secondaryWhite),
            enabled: true,
            controller: commentController,
            maxLines: 15,
            maxLength: 250,
            decoration: GlobalsStyle.setupTextFieldDecoration("Enter a comment (Optional)"),
          ),
        ),

        const SizedBox(height: 5),

        const Spacer(),

        Align(
          alignment: Alignment.bottomLeft,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child:Text("Tags", 
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              
              ValueListenableBuilder<String>(
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
              
            ],
          ),
        ),
        
        Container(
          color: ThemeColor.mediumGrey,
          width: mediaQuery.width,
          height: 82,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: ThemeColor.lightGrey, height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
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
                            borderRadius: BorderRadius.circular(18),
                          ),
                          backgroundColor: GlobalsStyle.psTagsToColor[tagsItems.elementAt(index)],
                        ),
                        onPressed: () {
                          psUploadData.setTagValue(tagsItems.elementAt(index));
                          selectedTagValue.value = psUploadData.psTagValue;
                        },
                        child: Text(tagsItems.elementAt(index)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

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

  Widget buildBackIconButton(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close),
      onPressed: () {
        clearValues();
        Navigator.pop(context);
      },
    );
  }
  
  void setValuesOnUpload() {
    titleController.text.isEmpty 
      ? psUploadData.setTitleValue("Untitled")
      : psUploadData.setTitleValue(titleController.text);

    psUploadData.setCommentValue(commentController.text);
    onUploadPressed();

    clearController();
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
            child: const Text("Upload",
                style: TextStyle(
                color: ThemeColor.darkPurple,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              if(selectedTagValue.value.isNotEmpty) {
                setValuesOnUpload();
                Navigator.pop(context);
              } else {
                CustomAlertDialog.alertDialog("Please select a tag.");
              }
            }
          ),
        ],
        title: const Text("Public Storage - Upload", 
          style: GlobalsStyle.appBarTextStyle
        ),
      ),
      body: buildBody(context),
    );
  }

}
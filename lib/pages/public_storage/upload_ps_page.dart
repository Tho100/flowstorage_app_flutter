import 'dart:convert';

import 'package:flowstorage_fsc/api/notification_api.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/ps_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/ui_dialog/alert_dialog.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flowstorage_fsc/widgets/buttons/right_text_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final getSizeMB = fileByte.lengthInBytes/(1024*1024);

    return getSizeMB.toDouble().toStringAsFixed(2);

  }

  Widget buildBody(BuildContext context) {
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

              const SizedBox(width: 10),

              if(Globals.generalFileTypes.contains(fileName.split('.').last))
              const SizedBox(width: 18),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    ShortenText().cutText(fileName),
                    style: GoogleFonts.inter(
                      color: ThemeColor.justWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "${fileSizeInMb()}Mb",
                    style: GoogleFonts.inter(
                      color: ThemeColor.thirdWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
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
            style: GoogleFonts.inter(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w800,
            ),
            enabled: true,
            controller: titleController,
            maxLines: 1,
            maxLength: 45,
            decoration: GlobalsStyle.setupTextFieldDecoration("Enter a title (Optional)"),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextFormField(
            style: GoogleFonts.inter(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w500,
            ),
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
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                
                Text("Select Tags ", 
                  style: GoogleFonts.inter(
                    color: ThemeColor.secondaryWhite,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.left,
                ),
                
                ValueListenableBuilder<String>(
                  valueListenable: selectedTagValue,
                  builder: (context, value, child) {
                    return Visibility(
                      visible: value != "",
                      child: Text(
                        "${GlobalsStyle.dotSeparator} $value",
                        style: GoogleFonts.inter(
                          color: GlobalsStyle.psTagsToColor[value],
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }
                ),
                
              ],
            ),
          ),
        ),
        
        Container(
          width: MediaQuery.of(context).size.width,
          height: 90,
          decoration: const BoxDecoration(
            color: ThemeColor.mediumGrey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 4.5, top: 5.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                  child: SizedBox(
                    height: 55,
                    child: ListView.builder(
                      itemCount: tagsItems.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Container(
                        margin: const EdgeInsets.all(6),
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
                          child: Row(
                            children: [
                              const Icon(Icons.label_outline, color: ThemeColor.justWhite,),
                              const SizedBox(width: 6), 
                              Text(tagsItems.elementAt(index)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
      appBar: CustomAppBar(
        context: context,
        title: "Public Storage",
        actions: [
          RightTextButton(
            text: "Upload",
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
      ).buildAppBar(),
      body: buildBody(context),
    );
  }

}
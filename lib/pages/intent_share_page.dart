import 'dart:convert';
import 'dart:typed_data';

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// ignore: must_be_immutable
class IntentSharingPage extends StatelessWidget {

  final String fileName;
  final String fileData;
  final String? imageBase64Encoded;

  IntentSharingPage({
    required this.fileName,
    required this.fileData,
    required this.imageBase64Encoded,
    Key? key
  }) : super(key: key);

  final storageData = GetIt.instance<StorageDataProvider>();

  late Uint8List fileBytes = Uint8List(0);

  Widget buildBody(BuildContext context) {

    return Column(
      children: [

        const SizedBox(height: 5),

        Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [

              if(Globals.imageType.contains(fileName.split('.').last) || Globals.videoType.contains(fileName.split('.').last))
              Stack(
                children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      base64.decode(imageBase64Encoded!),
                      width: 105,
                      height: 105,
                      fit: BoxFit.fitWidth,
                    )
                  ),
                ),

                if(Globals.videoType.contains(fileName.split('.').last))
                Padding(
                  padding: const EdgeInsets.only(top: 18.0, left: 20.0),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: ThemeColor.mediumGrey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 22)
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 10),

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

  void processFileUpload(String fileName, BuildContext context) {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        automaticallyImplyLeading: true,
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
              processFileUpload(fileName, context);
            }
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
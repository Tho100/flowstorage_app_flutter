import 'dart:typed_data';

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PsStaggeredListView extends StatelessWidget {

  final Uint8List imageBytes;
  final int index;
  final String uploaderName;
  final String fileType;
  final String originalDateValues;
  final Function callBottomTrailing;
  final Function downloadOnPressed;

  PsStaggeredListView({
    required this.imageBytes,
    required this.index,
    required this.uploaderName,
    required this.fileType,
    required this.originalDateValues,
    required this.callBottomTrailing,
    required this.downloadOnPressed,
    Key? key
  }) : super(key: key);

  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  Widget buildAccessButton({
    required bool isFromDownload,
    required VoidCallback onPressed, 
    required Widget child
  }) {
    return Padding(
      padding: isFromDownload 
        ? const EdgeInsets.only(left: 16.0) 
        : const EdgeInsets.only(right: 16.0),
      child: Align(
        alignment: isFromDownload ? Alignment.bottomLeft : Alignment.bottomRight,
        child: SizedBox(
          width: isFromDownload ? 56 : 132, 
          height: isFromDownload ? 40 : 40,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(ThemeColor.darkBlack),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isFromDownload ? 12 : 18),
                  side: const BorderSide(color: ThemeColor.lightGrey, width: 1),
                ),
              ),
            ),
            onPressed: onPressed,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context).size;

    return Container(
      width: mediaQuery.width,
      color: ThemeColor.darkBlack,
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "$uploaderName ${GlobalsStyle.dotSeperator} $originalDateValues",
                      style: const TextStyle(
                          color: ThemeColor.secondaryWhite, fontSize: 15, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  callBottomTrailing(index);
                },
                icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
              ),

            ],
          ),

          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: MediaQuery.of(context).size.width-102,
                child: Text(
                  psStorageData.psTitleList[index],
                  style: const TextStyle(
                    color: ThemeColor.justWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ShortenText().cutText(storageData.fileNamesFilteredList[index], customLength: 37),
                style: const TextStyle(
                  color: ThemeColor.secondaryWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
                textAlign: TextAlign.start,
              ),
            ),
          ),
          
          const SizedBox(height: 10),

          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 108,
                    height: 25,
                    decoration: BoxDecoration(
                      color: GlobalsStyle.psTagsToColor[psStorageData.psTagsList[index]],
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Center(
                      child: Text(
                        psStorageData.psTagsList[index],
                        style: const TextStyle(color: ThemeColor.justWhite, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Expanded(
            child: Stack(
              children: [
                
                Container(
                  width: Globals.generalFileTypes.contains(fileType) ? 72 : mediaQuery.width - 33,
                  height: Globals.generalFileTypes.contains(fileType) ? 72 : 338,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: ThemeColor.lightGrey,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                    child: Image.memory(imageBytes, fit: BoxFit.cover),
                  ),
                ),

                if (Globals.videoType.contains(fileType))
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 8),
                  child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ThemeColor.mediumGrey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 30)),
                ),

              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              buildAccessButton(
                isFromDownload: true,
                child: const Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.download, color: ThemeColor.justWhite, size: 21)
                ),
                onPressed: () async { 
                  final fileName = storageData.fileNamesFilteredList[index];
                  await downloadOnPressed(fileName: fileName); 
                },
              ),

              buildAccessButton(
                isFromDownload: false,
                child: const Row(
                  children: [
                    Icon(Icons.comment_outlined, color: ThemeColor.justWhite, size: 21),
                    SizedBox(width: 8),
                    Text("Comments")
                  ]
                ),
                onPressed: () {
                  final fileName = storageData.fileNamesFilteredList[index];
                  NavigatePage.goToPageFileComment(context, fileName);
                }
              ),

            ],
          ),
         
          const SizedBox(height: 4),
          const Divider(color: ThemeColor.whiteGrey),

        ],
      ),
    );
  }

}
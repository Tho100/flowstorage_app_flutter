import 'dart:typed_data';

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/video_placeholder_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class PsGridListView extends StatelessWidget {

  final Uint8List imageBytes;
  final int index;
  final String uploaderName;
  final String fileType;
  final String originalDateValues;
  final Function callBottomTrailing;
  final Function downloadOnPressed;

  PsGridListView({
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
    required bool isMiniActionButton,
    required EdgeInsets customPadding,
    required VoidCallback onPressed, 
    required Widget child
  }) {
    return Padding(
      padding: customPadding,
      child: Align(
        alignment: isMiniActionButton
          ? Alignment.bottomRight : Alignment.bottomLeft,
        child: SizedBox(
          width: isMiniActionButton ? 52 : 126, 
          height: isMiniActionButton ? 37 : 36,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(ThemeColor.darkBlack),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMiniActionButton ? 12 : 16),
                  side: const BorderSide(
                    color: ThemeColor.lightGrey
                  ),
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
    
    final isGeneralFile = Globals.generalFileTypes.contains(fileType);

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
                    child: Text("$uploaderName ${GlobalsStyle.dotSeparator} $originalDateValues",
                      style: GoogleFonts.inter(
                        color: ThemeColor.secondaryWhite, 
                        fontSize: 14, 
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ),

              IconButton(
                onPressed: () => callBottomTrailing(index),
                icon: const Icon(CupertinoIcons.ellipsis_vertical, color: Colors.white, size: 22),
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
                  style: GoogleFonts.inter(
                    color: ThemeColor.justWhite,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
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
                style: GoogleFonts.inter(
                  color: ThemeColor.secondaryWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
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
                        style: GoogleFonts.inter(
                          color: ThemeColor.justWhite, 
                          fontWeight: FontWeight.w800
                        ),
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
                  width: isGeneralFile ? mediaQuery.width - 33 : mediaQuery.width - 33,
                  height: isGeneralFile ? 175 : 395,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ThemeColor.lightGrey,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: Image.memory(
                      imageBytes, 
                      cacheHeight: isGeneralFile ? 55 : null,
                      cacheWidth: isGeneralFile ? 55 : null,
                      fit: isGeneralFile 
                      ? BoxFit.scaleDown : BoxFit.cover
                    ) 
                  ),
                ), 
                 
                if (Globals.videoType.contains(fileType))
                const Padding(
                  padding: EdgeInsets.only(left: 10, top: 8),
                  child: VideoPlaceholderWidget(
                    customHeight: 40,
                    customWidth: 40,
                    customIconSize: 30,
                  )
                ),
        
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
        
              buildAccessButton(
                isMiniActionButton: false,
                customPadding: const EdgeInsets.only(left: 17.5),
                child: Row(
                  children: [

                    const Icon(CupertinoIcons.bubble_left, color: ThemeColor.justWhite, size: 19),
                    
                    const SizedBox(width: 8),

                    Text("Comments", 
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 12
                      )
                    ),
                    
                  ]
                ),
                onPressed: () {
                  final fileName = storageData.fileNamesFilteredList[index];
                  tempData.setCurrentFileName(fileName);
                  NavigatePage.goToPageFileComment(fileName);
                }
              ),

              const Spacer(),

              buildAccessButton(
                isMiniActionButton: true,
                customPadding: const EdgeInsets.only(right: 8.5),
                child: const Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.file_download_outlined, color: ThemeColor.justWhite, size: 20)
                ),
                onPressed: () async { 
                  final fileName = storageData.fileNamesFilteredList[index];
                  tempData.setCurrentFileName(fileName);
                  await downloadOnPressed(fileName: fileName); 
                },
              ),
              
              buildAccessButton(
                isMiniActionButton: true,
                customPadding: const EdgeInsets.only(right: 17.5),
                child: const Align(
                  alignment: Alignment.center,
                  child: Icon(CupertinoIcons.arrowshape_turn_up_right, color: ThemeColor.justWhite, size: 19)
                ),
                onPressed: () { 
                  final fileName = storageData.fileNamesFilteredList[index];
                  NavigatePage.goToPageSharing(fileName);
                },
              ),

            ],
          ),
         
          const SizedBox(height: 6),
          const Divider(color: ThemeColor.lightGrey),

        ],
      ),
    );
  }

}
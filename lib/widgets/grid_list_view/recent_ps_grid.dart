import 'dart:typed_data';

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/video_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentPsListView extends StatelessWidget {

  final Uint8List imageBytes;
  final int index;
  final String uploadDate;
  final VoidCallback fileOnPressed;
  final VoidCallback fileOnLongPressed;

  RecentPsListView({
    required this.imageBytes,
    required this.index,
    required this.uploadDate,
    required this.fileOnPressed,
    required this.fileOnLongPressed,
    Key? key
  }) : super(key: key);

  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();

  @override
  Widget build(BuildContext context) {

    final fileName = storageData.fileNamesFilteredList[index];
    final fileType = fileName.split('.').last;

    final isGeneralFile = Globals.generalFileTypes.contains(fileType);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: fileOnPressed,
      onLongPress: fileOnLongPressed,
      child: Row(
        children: [
          
          const SizedBox(width: 3),

          Stack(
            children: [

              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeColor.lightGrey,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12)
                  ),
                  child: Image.memory(
                    imageBytes, 
                    cacheHeight: isGeneralFile ? 45 : null,
                    cacheWidth: isGeneralFile ? 45 : null,
                    fit: isGeneralFile ? BoxFit.scaleDown : BoxFit.cover
                    ),
                ),
              ),

              if(Globals.videoType.contains(fileType))
              const Padding(
                padding: EdgeInsets.only(top: 14.0, left: 16.0),
                child: VideoPlaceholderWidget(),
              ),

            ],
          ),

          const SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                ShortenText().cutText(psStorageData.psTitleList[index], customLength: 17),
                style: GoogleFonts.inter(
                  color: ThemeColor.justWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              Text(
                "${ShortenText().cutText(psStorageData.psUploaderList[index], customLength: 12)} ${GlobalsStyle.dotSeparator} $uploadDate",
                style: GoogleFonts.inter(
                  color: ThemeColor.secondaryWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                width: 100,
                height: 23,
                decoration: BoxDecoration(
                  color: GlobalsStyle.psTagsToColor[psStorageData.psTagsList[index]],
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Center(
                  child: Text(
                    psStorageData.psTagsList[index],
                    style: GoogleFonts.inter(
                      color: ThemeColor.justWhite,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),

              const SizedBox(height: 3),

            ],
          ),

          const SizedBox(width: 3),

        ],
      ),
    );
  }

}
import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/video_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DefaultGridListView extends StatelessWidget {

  final Uint8List imageBytes;
  final String fileType;
  final int index;

  DefaultGridListView({
    required this.imageBytes,
    required this.fileType,
    required this.index,
    Key? key,
  }) : super(key: key);

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  String getProperDate(String date) {
    final dotIndex = date.indexOf(GlobalsStyle.dotSeparator);
    return dotIndex != -1 
      ? date.substring(dotIndex + 4) 
      : date;
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    
    final actualFileType = fileType.split('.').last;

    final isGeneralFile = Globals.generalFileTypes.contains(actualFileType) || !fileType.contains('.');
    final isOfflineVideo = tempData.origin == OriginFile.offline && Globals.videoType.contains(fileType);

    final fileNames = storageData.fileNamesFilteredList[index];
    final fileDates = getProperDate(storageData.fileDateFilteredList[index]);

    return Column(
      children: [
        
        const SizedBox(height: 14),
  
        Expanded(
          child: Stack(
            children: [
              Container(
                width: size.width - 95,
                height: 145,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: ThemeColor.mediumGrey,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Image.memory(imageBytes,
                    cacheHeight: isGeneralFile ? 55 : null,
                    cacheWidth: isGeneralFile ? 55 : null,
                    fit: isGeneralFile || isOfflineVideo ? BoxFit.scaleDown : BoxFit.cover,
                  ),
                ),
              ),
              if (Globals.videoType.contains(actualFileType))
              const Align(
                alignment: Alignment.center,
                child: VideoPlaceholderWidget(
                  customHeight: 35,
                  customWidth: 35,
                  customIconSize: 24,
                ),
              ),
            ],
          ),
        ),
  
        const SizedBox(height: 10),
        
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 4),
            child: SizedBox(
              width: size.width-95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileNames,
                    style: const TextStyle(
                      color: ThemeColor.justWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileDates,
                    style: const TextStyle(
                      color: ThemeColor.secondaryWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
          
      ],

    );
  }

}
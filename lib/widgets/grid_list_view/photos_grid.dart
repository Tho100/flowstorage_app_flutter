import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/video_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PhotosGridListView extends StatelessWidget {
  
  final bool isPhotosSelected;
  final bool isSelectionNotEmpty;
  final Uint8List imageBytes;
  final String fileType;  

  PhotosGridListView({
    required this.imageBytes,
    required this.fileType,
    required this.isPhotosSelected,
    required this.isSelectionNotEmpty,
    Key? key
  }) : super(key: key);

  final tempData = GetIt.instance<TempDataProvider>();

  @override
  Widget build(BuildContext context) {

    final isOfflineVideo = tempData.origin == OriginFile.offline && Globals.videoType.contains(fileType);

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [

              Container(
                width: 335,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isPhotosSelected ? ThemeColor.secondaryWhite : ThemeColor.mediumGrey,
                    width: isPhotosSelected ? 2.8 : 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(imageBytes, 
                    fit: isOfflineVideo ? BoxFit.scaleDown : BoxFit.cover
                  ),
                ),
              ),
                
              if(Globals.videoType.contains(fileType))
              const Center(
                child: VideoPlaceholderWidget(
                  customWidth: 35, 
                  customHeight: 35, 
                  customIconSize: 24
                ),
              ),
            
              if(isPhotosSelected)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 12),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: ThemeColor.thirdWhite.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.check, 
                    color: ThemeColor.justWhite, size: 18)
                ),
              ),
              
              if(isSelectionNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 12),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: ThemeColor.thirdWhite.withOpacity(0.4),
                    border: Border.all(
                      color: ThemeColor.justWhite.withOpacity(0.7),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }

}
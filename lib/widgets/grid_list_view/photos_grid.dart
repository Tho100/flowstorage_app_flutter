import 'dart:typed_data';

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/video_placeholder_widget.dart';
import 'package:flutter/material.dart';

class PhotosGridListView extends StatelessWidget {
  
  final bool isPhotosSelected;
  final Uint8List imageBytes;
  final String fileType;

  const PhotosGridListView({
    required this.imageBytes,
    required this.fileType,
    required this.isPhotosSelected,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    color: isPhotosSelected ? ThemeColor.secondaryWhite : ThemeColor.darkBlack,
                    width: isPhotosSelected ? 2.8 : 1.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(imageBytes, fit: BoxFit.cover),
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
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: ThemeColor.darkPurple.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.check, color: ThemeColor.justWhite, size: 17)),
              ),
              
            ],
          ),
        ),

      ],
    );
  }

}
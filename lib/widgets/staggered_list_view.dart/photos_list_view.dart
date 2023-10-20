import 'dart:typed_data';

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class PhotosStaggeredListView extends StatelessWidget {
  
  final bool isPhotosSelected;
  final Uint8List imageBytes;
  final String fileType;

  const PhotosStaggeredListView({
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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPhotosSelected ? ThemeColor.secondaryWhite : ThemeColor.lightGrey,
                    width: isPhotosSelected ? 2.8 : 1.6,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(imageBytes, fit: BoxFit.cover),
                ),
              ),
                
              if(Globals.videoType.contains(fileType))
              Center(
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: ThemeColor.mediumGrey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 25)),
              ),
            
              if(isPhotosSelected)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 12),
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
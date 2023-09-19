import 'dart:typed_data';

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class PhotosStaggeredListView extends StatelessWidget {
  
  final Uint8List imageBytes;
  final String fileType;

  const PhotosStaggeredListView({
    required this.imageBytes,
    required this.fileType,
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
                    color: ThemeColor.lightGrey,
                    width: 1.6,
                  )
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(imageBytes, fit: BoxFit.cover)
                ),
              ),
          
              if(Globals.videoType.contains(fileType))
              const Padding(
                padding: EdgeInsets.only(left: 6.0, top: 4.0),
                child: Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 26),
              ),
            ],
          ),
        ),

      ],
    );
  }

}
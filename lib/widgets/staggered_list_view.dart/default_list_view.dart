import 'dart:typed_data';

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DefaultStaggeredListView extends StatelessWidget {

  final Uint8List imageBytes;
  final String fileType;
  final int index;

  DefaultStaggeredListView({
    required this.imageBytes,
    required this.fileType,
    required this.index,
    Key? key,
  }) : super(key: key);

  final storageData = GetIt.instance<StorageDataProvider>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
              width: 89,
              height: 89,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Image.memory(imageBytes, fit: BoxFit.cover),
                ),
              ),
              
              if(Globals.videoType.contains(fileType))
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 24),
                child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: ThemeColor.mediumGrey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 25)),
              ),
            
            ],
          ),
        ),

        const SizedBox(height: 10),
        
        Text(
          ShortenText().cutText(storageData.fileNamesFilteredList[index], customLength: 11),
          style: const TextStyle(
            color: ThemeColor.justWhite,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 10) 

      ],
    );
  }

}
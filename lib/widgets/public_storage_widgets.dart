import 'dart:typed_data';

import 'package:flowstorage_fsc/helper/date_short_form.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/grid_list_view/recent_ps_grid.dart';
import 'package:flowstorage_fsc/widgets/grid_list_view/sub_ps_grid.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class PublicStorageWidgets {

  final Function? navigateToPreviewFile;
  final Function? callBottomTrailing;

  PublicStorageWidgets({
    this.navigateToPreviewFile,
    this.callBottomTrailing
  });

  final storageData = GetIt.instance<StorageDataProvider>();

  Widget _buildRecentPsFiles(Uint8List imageBytes, int index) {

    final originalDateValues = storageData.fileDateFilteredList[index];

    final daysDate = originalDateValues.split(' ')[0];
    final inputDate = "$daysDate days";
    final shortFormDate = inputDate == "Just days" 
      ? "Just now" 
      : DateShortForm(input: inputDate).convert();

    return RecentPsListView(
      imageBytes: imageBytes, 
      index: index, 
      uploadDate: shortFormDate,
      fileOnPressed: () => navigateToPreviewFile!(index),
      fileOnLongPressed: () => callBottomTrailing!(index),
    );

  }

  Widget _buildSubPsFiles(Uint8List imageBytes, int index) {

    final originalDateValues = storageData.fileDateFilteredList[index];

    final daysDate = originalDateValues.split(' ')[0];
    final inputDate = "$daysDate days";
    final shortFormDate = inputDate == "Just days" 
      ? "Just now" 
      : DateShortForm(input: inputDate).convert();

    return SubPsListView(
      imageBytes: imageBytes, 
      index: index, 
      uploadDate: shortFormDate,
      fileOnPressed: () => navigateToPreviewFile!(index), 
      fileOnLongPressed: () => callBottomTrailing!(index),
    ); 

  }

  Widget buildRecentFiles() {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 12),
            child: Row(
              children: [

                const Icon(Icons.schedule, color: ThemeColor.justWhite, size: 20),

                const SizedBox(width: 8),

                Text(
                  "Recent",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    color: ThemeColor.justWhite,
                    fontWeight: FontWeight.w800,
                  ),
                ),

              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [

              const SizedBox(width: 10),
              _buildRecentPsFiles(storageData.imageBytesFilteredList[0]!, 0),

              if (storageData.imageBytesFilteredList.length > 1) ... [
                const SizedBox(width: 25),
                _buildRecentPsFiles(storageData.imageBytesFilteredList[1]!, 1),
              ],

              if (storageData.imageBytesFilteredList.length > 2) ... [
                const SizedBox(width: 25),
                _buildRecentPsFiles(storageData.imageBytesFilteredList[2]!, 2),
              ],

              const SizedBox(width: 15),

            ],
          ),
        ),

        const SizedBox(height: 8),

        const Divider(color: ThemeColor.lightGrey),

      ],
    );

  }

  Widget buildSubFiles() {
    return Transform.translate(
      offset: const Offset(0, -12),
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [

              const SizedBox(width: 5),
              _buildSubPsFiles(storageData.imageBytesFilteredList[3]!, 3),
              
              const SizedBox(width: 26),
              if (storageData.imageBytesFilteredList.length > 4)
              _buildSubPsFiles(storageData.imageBytesFilteredList[4]!, 4),
    
              const SizedBox(width: 26),
              if (storageData.imageBytesFilteredList.length > 5)
              _buildSubPsFiles(storageData.imageBytesFilteredList[5]!, 5),
    
              const SizedBox(width: 26),
              if (storageData.imageBytesFilteredList.length > 6)
              _buildSubPsFiles(storageData.imageBytesFilteredList[6]!, 6),
    
              const SizedBox(width: 5),

            ],
          ),
        ),
      ),
    );
  }

  Widget buildDiscoverText() {
    return Transform.translate(
      offset: const Offset(0, -12),  
      child: Padding(
        padding: const EdgeInsets.only(left: 18.0),
        child: Row(
          children: [

            const Icon(Icons.explore_outlined, color: ThemeColor.justWhite, size: 20),

            const SizedBox(width: 8),

            Text( 
              "Discover",
              style: GoogleFonts.inter(
                fontSize: 22,
                color: ThemeColor.justWhite,
                fontWeight: FontWeight.w800,
              ),
            ),

          ],
        ),
      ),
    );
  }

}
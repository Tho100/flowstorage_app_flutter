import 'package:flowstorage_fsc/global/globals_style.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class BottomTrailingAddItem {
  
  Future buildTrailing({
    required String headerText,
    required VoidCallback galleryOnPressed,
    required VoidCallback fileOnPressed,
    required VoidCallback folderOnPressed,
    required VoidCallback photoOnPressed,
    required VoidCallback scannerOnPressed,
    required VoidCallback textOnPressed,
    required VoidCallback directoryOnPressed,
    required BuildContext context
  }) {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    headerText,
                    style: const TextStyle(
                      color: ThemeColor.secondaryWhite,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
    
            Visibility(
              visible: VisibilityChecker.setNotVisibleList([OriginFile.offline, OriginFile.public]),
              child: ElevatedButton(
                onPressed: galleryOnPressed,
                style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                child: const Row(
                  children: [
                    Icon(Icons.photo_outlined),
                    SizedBox(width: 15.0),
                    Text(
                      'Upload from gallery',
                      style: GlobalsStyle.btnBottomDialogTextStyle
                    ),
                  ],
                ),
              ),
            ),

            ElevatedButton(
              onPressed: fileOnPressed,
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.upload_file_outlined),
                  SizedBox(width: 15.0),
                  Text(
                    'Upload files',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),

            Visibility(
              visible: VisibilityChecker.setNotVisibleList([OriginFile.offline , OriginFile.public, OriginFile.directory, OriginFile.folder]),
              child: ElevatedButton(
              onPressed: folderOnPressed,
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.folder_outlined),
                  SizedBox(width: 15.0),
                  Text('Upload folder',
                    style: GlobalsStyle.btnBottomDialogTextStyle
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(color: ThemeColor.thirdWhite),

          ElevatedButton(
            onPressed: photoOnPressed,
            style: GlobalsStyle.btnBottomDialogBackgroundStyle,
            child: const Row(
              children: [
                Icon(Icons.camera_alt_outlined),
                SizedBox(width: 15.0),
                Text(
                  'Take a photo',
                  style: GlobalsStyle.btnBottomDialogTextStyle,
                ),
              ],
            ),
          ),

          Visibility(
            visible: VisibilityChecker.setNotVisibleList([OriginFile.public, OriginFile.offline]),
            child: ElevatedButton(
              onPressed: scannerOnPressed,
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.center_focus_strong_outlined),
                  SizedBox(width: 15.0),
                  Text(
                    'Scan document',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),
          ),

          const Divider(color: ThemeColor.thirdWhite),

          Visibility(
            visible: VisibilityChecker.setNotVisible(OriginFile.public),
            child: ElevatedButton(
              onPressed: textOnPressed,
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                child: const Row(
                  children: [
                    Icon(Icons.add_box_outlined),
                    SizedBox(width: 15.0),
                    Text(
                      'Create text file',
                      style: GlobalsStyle.btnBottomDialogTextStyle,
                    ),
                  ],
                ),
              ),
            ),
        
            Visibility(
              visible: VisibilityChecker.setNotVisibleList([OriginFile.public, OriginFile.directory, OriginFile.folder, OriginFile.offline]),
              child: ElevatedButton(
              onPressed: directoryOnPressed,
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
                child: const Row(
                  children: [
                    Icon(Icons.add_box_outlined),
                    SizedBox(width: 15.0),
                    Text(
                      'Create directory',
                      style: GlobalsStyle.btnBottomDialogTextStyle,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
    );
  }

}
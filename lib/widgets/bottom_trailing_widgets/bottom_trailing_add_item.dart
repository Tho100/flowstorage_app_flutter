import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BottomTrailingAddItem {
  
  final tempData = GetIt.instance<TempDataProvider>();

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

            const SizedBox(height: 12),

            const SheetBar(),

            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0, top: 25.0),
                child: Text(
                  headerText,
                  style: const TextStyle(
                    color: ThemeColor.secondaryWhite,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            const Divider(color: ThemeColor.lightGrey),
    
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

          if(tempData.origin != OriginFile.public) ... [
            const Divider(color: ThemeColor.lightGrey),

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
          ],

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

          if(tempData.origin != OriginFile.public) ... [
            const Divider(color: ThemeColor.lightGrey),

            ElevatedButton(
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
            ],    
        
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
            const SizedBox(height: 20),
          ],
        );
      }
    );
  }

}
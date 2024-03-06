import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
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
    return BottomTrailing().buildTrailing(
      context: context,
      children: [

        const SizedBox(height: 12),

        const BottomSheetBar(),

        BottomTrailingTitle(title: headerText),
        
        const Divider(color: ThemeColor.lightGrey),

        if(WidgetVisibility.setNotVisible(OriginFile.public))
        ElevatedButton(
          onPressed: galleryOnPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.photo_outlined, color: ThemeColor.secondaryWhite),
              SizedBox(width: 15.0),
              Text(
                'Upload from gallery',
                style: GlobalsStyle.btnBottomDialogTextStyle
              ),
            ],
          ),
        ),
        
        ElevatedButton(
          onPressed: fileOnPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.upload_file_outlined, color: ThemeColor.secondaryWhite),
              SizedBox(width: 15.0),
              Text(
                'Upload files',
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),

        if(WidgetVisibility.setVisible(OriginFile.home))
        ElevatedButton(
          onPressed: folderOnPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.folder_outlined, color: ThemeColor.secondaryWhite),
              SizedBox(width: 15.0),
              Text('Upload folder',
                style: GlobalsStyle.btnBottomDialogTextStyle
              ),
            ],
          ),
        ),

        if(WidgetVisibility.setNotVisible(OriginFile.public)) ... [
        const Divider(color: ThemeColor.lightGrey),

        ElevatedButton(
          onPressed: photoOnPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.camera_alt_outlined, color: ThemeColor.secondaryWhite),
              SizedBox(width: 15.0),
              Text(
                'Take a photo',
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),
      ],

      if(WidgetVisibility.setNotVisible(OriginFile.public))
      ElevatedButton(
        onPressed: scannerOnPressed,
        style: GlobalsStyle.btnBottomDialogBackgroundStyle,
        child: const Row(
          children: [
            Icon(Icons.center_focus_strong_outlined, color: ThemeColor.secondaryWhite),
            SizedBox(width: 15.0),
            Text(
              'Scan document',
              style: GlobalsStyle.btnBottomDialogTextStyle,
            ),
          ],
        ),
      ),
    
      if(WidgetVisibility.setNotVisible(OriginFile.public)) ... [
        const Divider(color: ThemeColor.lightGrey),

        ElevatedButton(
          onPressed: textOnPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
            child: const Row(
              children: [
                Icon(Icons.add_box_outlined, color: ThemeColor.secondaryWhite),
                SizedBox(width: 15.0),
                Text(
                  'Create text file',
                  style: GlobalsStyle.btnBottomDialogTextStyle,
                ),
              ],
            ),
          ),
        ],    

        if(WidgetVisibility.setVisible(OriginFile.home))
        ElevatedButton(
          onPressed: directoryOnPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
            child: const Row(
              children: [
                Icon(Icons.add_box_outlined, color: ThemeColor.secondaryWhite),
                SizedBox(width: 15.0),
                Text(
                  'Create directory',
                  style: GlobalsStyle.btnBottomDialogTextStyle,
                ),
              ],
            ),
          ),
        
        const SizedBox(height: 20),
        
      ],
    );
  }

}
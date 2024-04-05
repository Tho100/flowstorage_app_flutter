import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

class BottomTrailingAddItem {
  
  Widget _buildAddItemButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: GlobalsStyle.btnBottomDialogBackgroundStyle,
      child: Row(
        children: [
          Icon(icon, color: ThemeColor.secondaryWhite),
          const SizedBox(width: 15.0),
          Text(
            text,
            style: GlobalsStyle.btnBottomDialogTextStyle
          ),
        ],
      ),
    );
  }

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

        const BottomTrailingBar(),

        BottomTrailingTitle(title: headerText),
        
        const Divider(color: ThemeColor.lightGrey),

        _buildAddItemButton(
          text: "Upload from gallery",
          icon: Icons.photo_outlined,
          onPressed: galleryOnPressed
        ),
        
        _buildAddItemButton(
          text: "Upload files",
          icon: Icons.upload_file_outlined,
          onPressed: fileOnPressed
        ),

        if(WidgetVisibility.setVisible(OriginFile.home))
        _buildAddItemButton(
          text: "Upload folder",
          icon: Icons.folder_outlined,
          onPressed: folderOnPressed
        ),

        const Divider(color: ThemeColor.lightGrey),

        _buildAddItemButton(
          text: "Take a photo",
          icon: Icons.camera_alt_outlined,
          onPressed: photoOnPressed
        ),

        _buildAddItemButton(
          text: "Scan document",
          icon: Icons.center_focus_strong_outlined,
          onPressed: scannerOnPressed
        ),
      
        const Divider(color: ThemeColor.lightGrey),

        _buildAddItemButton(
          text: "Create text file",
          icon: Icons.add_box_outlined,
          onPressed: textOnPressed
        ),
        
        if(WidgetVisibility.setVisible(OriginFile.home))
        _buildAddItemButton(
          text: "Create directory",
          icon: Icons.add_box_outlined,
          onPressed: directoryOnPressed
        ),
        
        const SizedBox(height: 20),
        
      ],
    );
  }

}
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

class BottomTrailingFolder {

  Widget _buildOptionButton({
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
            style: GlobalsStyle.btnBottomDialogTextStyle,
          ),
        ],
      ),
    );
  }

  Future buildFolderBottomTrailing({
    required String folderName,
    required BuildContext context,
    required VoidCallback onRenamePressed,
    required VoidCallback onDownloadPressed,
    required VoidCallback onDeletePressed
  }) {
    return BottomTrailing().buildTrailing(
      context: context, 
      children: [

        const SizedBox(height: 12),

        const BottomTrailingBar(),

        BottomTrailingTitle(title: folderName.length > 50 ? "${folderName.substring(0,50)}..." : "$folderName Folder"),

        const Divider(color: ThemeColor.lightGrey),
          
        _buildOptionButton(
          text: "Rename folder",
          icon: Icons.edit_outlined,
          onPressed: () {
            Navigator.pop(context);
            onRenamePressed();
          }
        ),
        
        _buildOptionButton(
          text: "Download",
          icon: Icons.file_download_outlined,
          onPressed: () => onDownloadPressed(),
        ),

        _buildOptionButton(
          text: "Delete",
          icon: Icons.delete_outline,
          onPressed: () async {
            Navigator.pop(context);
            onDeletePressed();
          },
        ),

        const SizedBox(height: 20),
        
      ],
    );

  }
}
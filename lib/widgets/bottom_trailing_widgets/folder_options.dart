import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

class BottomTrailingFolder {

  Future buildFolderBottomTrailing({
    required String folderName,
    required BuildContext context,
    required VoidCallback onRenamePressed,
    required VoidCallback onDownloadPressed,
    required VoidCallback onDeletePressed
  }) {
    return BottomTrailing().buildTrailing(
      context: context, 
      childrens: <Widget>[

        const SizedBox(height: 12),

        const BottomSheetBar(),

        BottomTrailingTitle(title: folderName.length > 50 ? "${folderName.substring(0,50)}..." : "$folderName Folder"),

        const Divider(color: ThemeColor.lightGrey),
          
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onRenamePressed();
          },
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 15.0),
              Text(
                'Rename folder',
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),

        ElevatedButton(
          onPressed: () { onDownloadPressed(); },
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.file_download_outlined),
              SizedBox(width: 15.0),
              Text('Download',
                style: GlobalsStyle.btnBottomDialogTextStyle
              ),
            ],
          ),
        ),

        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context);
            onDeletePressed();
          },

          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.delete_outline,color: ThemeColor.darkRed),
              SizedBox(width: 15.0),
              Text('Delete',
                style: TextStyle(
                  color: ThemeColor.darkRed,
                  fontSize: 17,
                )
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        
      ],
    );

  }
}
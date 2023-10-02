import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class BottomTrailingFolder {

  Future buildFolderBottomTrailing({
    required String folderName,
    required BuildContext context,
    required VoidCallback onRenamePressed,
    required VoidCallback onDownloadPressed,
    required VoidCallback onDeletePressed
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

            Align(
              alignment: Alignment.center,
              child: Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  color: ThemeColor.thirdWhite,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0, top: 25.0),
                child: Text(
                  folderName.length > 50 ? "${folderName.substring(0,50)}..." : "$folderName Folder",
                  style: const TextStyle(
                    color: ThemeColor.secondaryWhite,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            const Divider(color: ThemeColor.lightGrey),
              
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onRenamePressed();
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 15.0),
                  Text(
                    'Rename Folder',
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
                  Icon(Icons.download_rounded),
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
                  Icon(Icons.delete,color: ThemeColor.darkRed),
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
    );
  }
}
import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BottomTrailingOptions {

  final storageData = GetIt.instance<StorageDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  Future buildBottomTrailing({
    required String fileName,
    required VoidCallback onRenamePressed,
    required VoidCallback onDownloadPressed,
    required VoidCallback onDeletePressed,
    required VoidCallback onSharingPressed,
    required VoidCallback onAOPressed,
    required VoidCallback onOpenWithPressed,
    required BuildContext context
  }) {

    final fileType = fileName.split('.').last;

    return BottomTrailing().buildTrailing(
      context: context,
      childrens: <Widget>[

        const SizedBox(height: 12),

        const BottomsheetBar(),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Padding(
              padding: const EdgeInsets.only(left: 12,top: 12, bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image(
                  width: Globals.generalFileTypes.contains(fileType) 
                    ? 46 : 60,
                  height: Globals.generalFileTypes.contains(fileType) 
                    ? 46 : 60,
                  fit: BoxFit.cover,
                  image: MemoryImage(storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexWhere((name) => name == fileName)]!),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 12.0, top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ShortenText().cutText(fileName, customLength: 50),
                      style: const TextStyle(
                        color: ThemeColor.justWhite,
                        fontSize: 15,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if(tempData.origin == OriginFile.public) ... [
                      const SizedBox(height: 2),
                      Text(
                        "Uploaded by ${psStorageData.psUploaderList.elementAt(storageData.fileNamesFilteredList.indexOf(fileName))}",
                        style: const TextStyle(
                          color: ThemeColor.secondaryWhite,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const Divider(color: ThemeColor.lightGrey),

        Visibility(
          visible: VisibilityChecker.setNotVisible(OriginFile.public),
          child: ElevatedButton(
            onPressed: onRenamePressed,
            style: GlobalsStyle.btnBottomDialogBackgroundStyle,
            child: Row(
              children: [
                const Icon(Icons.edit),
                const SizedBox(width: 15.0),
                Text(
                  fileName.contains('.') ? "Rename File" : "Rename Directory",
                  style: GlobalsStyle.btnBottomDialogTextStyle,
                ),
              ],
            ),
          ),
        ),

        if(fileName.split('.').last == "pdf" || Globals.textType.contains(fileName.split('.').last))
        ElevatedButton(
          onPressed: onOpenWithPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.open_in_new_outlined),
              SizedBox(width: 15.0),
              Text(
                "Open With",
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),
        

        Visibility(
          visible: VisibilityChecker.setNotVisible(OriginFile.offline) && fileName.split('.').last != fileName,
          child: ElevatedButton(
            onPressed: onSharingPressed,
            style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
              children: [
                Icon(Icons.share_rounded),
                SizedBox(width: 15.0),
                Text('Share File',
                  style: GlobalsStyle.btnBottomDialogTextStyle
                ),
              ],
            ),
          ),
        ),

        Visibility(
          visible: VisibilityChecker.setNotVisibleList([OriginFile.offline, OriginFile.public]),
          child: const Divider(color: ThemeColor.lightGrey)
        ),

        Visibility(
          visible: VisibilityChecker.setNotVisible(OriginFile.offline) && fileName.split('.').last != fileName,
          child: ElevatedButton(
            onPressed: onAOPressed,
            style: GlobalsStyle.btnBottomDialogBackgroundStyle,
            child: const Row(
              children: [
                Icon(Icons.offline_bolt_rounded),
                SizedBox(width: 15.0),
                Text('Make available Offline',
                  style: GlobalsStyle.btnBottomDialogTextStyle
                ),
              ],
            ),
          ),
        ),

        Visibility(
          visible: fileName.split('.').last != fileName,
          child: const Divider(color: ThemeColor.lightGrey)
        ),

        ElevatedButton(
          onPressed: onDownloadPressed,
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

        if((tempData.origin == OriginFile.public && tempData.appBarTitle != "Public Storage") || tempData.origin != OriginFile.public)
        ElevatedButton(
          onPressed: onDeletePressed,
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

}
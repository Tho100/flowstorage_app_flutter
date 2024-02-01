import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/shorten_text.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/report_options.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BottomTrailingOptions {

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  Future buildBottomTrailing({
    required String fileName,
    required VoidCallback onRenamePressed,
    required VoidCallback onDownloadPressed,
    required VoidCallback onDetailsPressed,
    required VoidCallback onDeletePressed,
    required VoidCallback onSharingPressed,
    required VoidCallback onAOPressed,
    required VoidCallback onOpenWithPressed,
    required VoidCallback onMovePressed,
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
                    ? 36 : 60,
                  height: Globals.generalFileTypes.contains(fileType) 
                    ? 36 : 60,
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
                    if(WidgetVisibility.setVisibileList([OriginFile.public, OriginFile.sharedMe, OriginFile.sharedOther])) ... [
                      const SizedBox(height: 2),
                      Text(
                        tempData.origin == OriginFile.public
                          ? "Uploaded by ${psStorageData.psUploaderList.elementAt(storageData.fileNamesFilteredList.indexOf(fileName))}"
                          : tempData.origin == OriginFile.sharedMe
                            ? "Uploaded by ${tempStorageData.sharedNameList.elementAt(storageData.fileNamesFilteredList.indexOf(fileName))}"
                            : tempData.origin == OriginFile.sharedOther
                              ? "Shared to ${tempStorageData.sharedNameList.elementAt(storageData.fileNamesFilteredList.indexOf(fileName))}"
                              : "Unknown",
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

        if(WidgetVisibility.setNotVisibleList([OriginFile.public, OriginFile.publicSearching]))
        ElevatedButton(
          onPressed: onRenamePressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined),
              const SizedBox(width: 15.0),
              Text(
                fileName.contains('.') ? "Rename file" : "Rename directory",
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),
        
        if(fileName.contains('.'))
        ElevatedButton(
          onPressed: onOpenWithPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.open_in_new_outlined),
              SizedBox(width: 15.0),
              Text(
                "Open with",
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ), 

        if(WidgetVisibility.setNotVisible(OriginFile.offline) && fileName.contains('.'))
        ElevatedButton(
          onPressed: onSharingPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
            child: const Row(
            children: [
              Icon(Icons.share_outlined),
              SizedBox(width: 15.0),
              Text('Share file',
                style: GlobalsStyle.btnBottomDialogTextStyle
              ),
            ],
          ),
        ),  

        if(WidgetVisibility.setNotVisible(OriginFile.offline))
        const Divider(color: ThemeColor.lightGrey),

        if(WidgetVisibility.setNotVisible(OriginFile.offline) && fileName.contains('.'))
        ElevatedButton(
          onPressed: onAOPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.offline_bolt_outlined),
              SizedBox(width: 15.0),
              Text('Make available offline',
                style: GlobalsStyle.btnBottomDialogTextStyle
              ),
            ],
          ),
        ),
        

        if(fileName.contains('.'))
        const Divider(color: ThemeColor.lightGrey),

        if(WidgetVisibility.setVisibileList([OriginFile.public, OriginFile.publicSearching]))
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            BottomTrailingReport(
              fileName: fileName, context: context).buildReportType();
          },
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.flag_outlined),
              SizedBox(width: 15.0),
              Text('Report',
                style: GlobalsStyle.btnBottomDialogTextStyle
              ),
            ],
          ),
        ),

        ElevatedButton(
          onPressed: onDownloadPressed,
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

        if(fileName.contains('.') && tempData.origin == OriginFile.home)
        ElevatedButton(
          onPressed: onMovePressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.open_with_outlined),
              SizedBox(width: 15.0),
              Text('Move',
                style: GlobalsStyle.btnBottomDialogTextStyle
              ),
            ],
          ),
        ),

        if(fileName.contains('.'))
        ElevatedButton(
          onPressed: onDetailsPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.info_outlined),
              SizedBox(width: 15.0),
              Text('Details',
                style: GlobalsStyle.btnBottomDialogTextStyle
              ),
            ],
          ),
        ),

        if((tempData.origin == OriginFile.public && tempData.appBarTitle != "Public Storage") || tempData.origin != OriginFile.public && tempData.origin != OriginFile.publicSearching)
        ElevatedButton(
          onPressed: onDeletePressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.delete_outline, color: ThemeColor.darkRed),
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
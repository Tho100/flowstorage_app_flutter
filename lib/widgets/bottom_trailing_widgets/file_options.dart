import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
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
            style: GlobalsStyle.btnBottomDialogTextStyle
          ),
        ],
      ),
    );
  }

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

    final isGeneralFile = Globals.generalFileTypes.contains(fileType);

    return BottomTrailing().buildTrailing(
      context: context,
      children: [

        const SizedBox(height: 12),

        const BottomTrailingBar(),
        
        Row(
          children: [

            Padding(
              padding: const EdgeInsets.only(left: 12,top: 12, bottom: 12),
              child: GestureDetector(
                onTap: () => NavigatePage.goToPagePongGame(),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image(
                    width: isGeneralFile 
                      ? 36 : 60,
                    height: isGeneralFile
                      ? 36 : 60,
                    fit: BoxFit.cover,
                    image: MemoryImage(storageData.imageBytesFilteredList[storageData.fileNamesFilteredList.indexWhere((name) => name == fileName)]!),
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 12.0, top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ShortenText().cutText(fileName, customLength: 50),
                      style: const TextStyle(
                        color: ThemeColor.secondaryWhite,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if(WidgetVisibility.setVisibleList([OriginFile.public, OriginFile.sharedMe, OriginFile.sharedOther])) ... [
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
                          color: ThemeColor.thirdWhite,
                          fontSize: 14,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.w600,
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
        _buildOptionButton(
          text: fileName.contains('.') ? "Rename file" : "Rename directory",
          icon: Icons.edit_outlined,
          onPressed: onRenamePressed
        ),
        
        if(fileName.contains('.'))
        _buildOptionButton(
          text: "Open with",
          icon: Icons.open_in_new_outlined,
          onPressed: onOpenWithPressed
        ),

        if(WidgetVisibility.setNotVisible(OriginFile.offline) && fileName.contains('.'))
        _buildOptionButton(
          text: "Share file",
          icon: Icons.share_outlined,
          onPressed: onSharingPressed
        ),

        if(WidgetVisibility.setNotVisible(OriginFile.offline))
        const Divider(color: ThemeColor.lightGrey),

        if(WidgetVisibility.setNotVisible(OriginFile.offline) && fileName.contains('.'))
        _buildOptionButton(
          text: "Make available offline",
          icon: Icons.offline_bolt_outlined,
          onPressed: onAOPressed
        ),
        
        if(fileName.contains('.'))
        const Divider(color: ThemeColor.lightGrey),

        if(WidgetVisibility.setVisibleList([OriginFile.public, OriginFile.publicSearching]))
        _buildOptionButton(
          text: "Report",
          icon: Icons.flag_outlined,
          onPressed: () {
            Navigator.pop(context);
            BottomTrailingReport(
              fileName: fileName, context: context).buildReportType();
          }
        ),

        _buildOptionButton(
          text: "Download",
          icon: Icons.file_download_outlined,
          onPressed: onDownloadPressed
        ),

        if(fileName.contains('.') && tempData.origin == OriginFile.home)
        _buildOptionButton(
          text: "Move",
          icon: Icons.open_with_outlined,
          onPressed: onMovePressed
        ),

        if(fileName.contains('.'))
        _buildOptionButton(
          text: "Details",
          icon: Icons.info_outlined,
          onPressed: onDetailsPressed
        ),

        if((tempData.origin == OriginFile.public && tempData.appBarTitle != "Public Storage") || tempData.origin != OriginFile.public && tempData.origin != OriginFile.publicSearching)
        _buildOptionButton(
          text: "Delete",
          icon: Icons.delete_outline,
          onPressed: onDeletePressed
        ),
      
        const SizedBox(height: 20),

      ],
    );

  }

}
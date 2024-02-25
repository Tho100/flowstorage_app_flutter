import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FolderDialog {

  final tempStorageData = GetIt.instance<TempStorageProvider>();

  Future buildFoldersBottomSheet({
    required Function(int) folderOnPressed,
    required Function(int) trailingOnPressed,
    required BuildContext context
  }) {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkBlack,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,  
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              
              const SizedBox(height: 12),

              const BottomSheetBar(),

              const BottomTrailingTitle(title: "Folders"),

              const Divider(color: ThemeColor.lightGrey),

              tempStorageData.folderNameList.isNotEmpty 
              ? Expanded(  
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: tempStorageData.folderNameList.length,
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 6, top: 2),
                    child: Divider(
                      color: ThemeColor.lightGrey,
                      height: 1,
                    ),
                  ),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () => folderOnPressed(index),
                      child: Ink(
                        child: ListTile(
                          leading: Image.asset(
                            'assets/images/dir1.jpg',
                            width: 35,
                            height: 35,
                          ),
                          title: Text(  
                            tempStorageData.folderNameList[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () => trailingOnPressed(index),
                            child: const Icon(Icons.more_vert, color: ThemeColor.secondaryWhite)),
                        ),
                      ),
                    );

                  },
                ),
              )
              : const SizedBox(
                height: 255,
                child: Center(
                  child: Text("No folder yet",
                    style: TextStyle(
                      color: ThemeColor.thirdWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ),
              ),

            ],
          ),
        );
      }
    );

  }

}
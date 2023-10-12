import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FolderDialog {

  final storageData = GetIt.instance<StorageDataProvider>();

  Future buildFoldersBottomSheet({
    required Function(int) folderOnPressed,
    required Function(int) trailingOnPressed,
    required BuildContext context
  }) {

    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,  
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              
              const SizedBox(height: 12),

              const BottomsheetBar(),

              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.0, top: 25.0),
                  child: Text(
                    "Folders",
                    style: TextStyle(
                      color: ThemeColor.secondaryWhite,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const Divider(color: ThemeColor.lightGrey),

              storageData.foldersNameList.isNotEmpty 
              ? Expanded(  
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: storageData.foldersNameList.length,
                  separatorBuilder: (BuildContext context, int index) => const Divider(
                    color: ThemeColor.whiteGrey,
                    height: 1,
                  ),
                  itemBuilder: (BuildContext context, int index) {
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
                            storageData.foldersNameList[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () => trailingOnPressed(index),
                            child: const Icon(Icons.more_vert, color: Colors.white)),
                        ),
                      ),
                    );

                  },
                ),
              )
              : const Center(
                child: Text("(Empty)",
                  style: TextStyle(
                    color: ThemeColor.thirdWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600
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
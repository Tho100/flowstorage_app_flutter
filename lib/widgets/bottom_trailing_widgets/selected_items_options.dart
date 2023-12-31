import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BottomTrailingSelectedItems {

  Future buildTrailing({
    required BuildContext context,
    required VoidCallback makeAoOnPressed,
    required VoidCallback saveOnPressed,
    required VoidCallback deleteOnPressed,
    required VoidCallback moveOnPressed,
    required Set<String> itemsName
  }) {

    final tempData = GetIt.instance<TempDataProvider>();

    return BottomTrailing().buildTrailing(
      context: context,
      childrens: <Widget>[

        const SizedBox(height: 12),

        const BottomsheetBar(),

        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0, top: 25.0),
            child: Text(
              tempData.appBarTitle,
              style: const TextStyle(
                color: ThemeColor.secondaryWhite,
                fontSize: 16,
              ),
            ),
          ),
        ),
        
        const Divider(color: ThemeColor.lightGrey),
        
        if(itemsName.every((name) => name.contains('.'))) ... [

          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              saveOnPressed();
            },
            style: GlobalsStyle.btnBottomDialogBackgroundStyle,
            child: const Row(
              children: [
                Icon(Icons.file_download_outlined),
                SizedBox(width: 15.0),
                Text(
                  'Save to device',
                  style: GlobalsStyle.btnBottomDialogTextStyle,
                ),
              ],
            ),
          ),

          Visibility(
            visible: VisibilityChecker.setNotVisible(OriginFile.offline) 
                  && itemsName.every((name) => !Globals.videoType.contains(name.split('.').last)),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                makeAoOnPressed();
              },
              style: GlobalsStyle.btnBottomDialogBackgroundStyle,
              child: const Row(
                children: [
                  Icon(Icons.offline_bolt_outlined),
                  SizedBox(width: 15.0),
                  Text(
                    'Make available offline',
                    style: GlobalsStyle.btnBottomDialogTextStyle,
                  ),
                ],
              ),
            ),
          ),
        
          if(tempData.origin == OriginFile.home)
          ElevatedButton(
            onPressed: moveOnPressed,
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

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteOnPressed();
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

        ],

        const SizedBox(height: 12),

      ],
    );

  }
}
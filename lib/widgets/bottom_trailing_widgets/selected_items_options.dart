import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BottomTrailingSelectedItems {

  final tempData = GetIt.instance<TempDataProvider>();

  Future buildTrailing({
    required BuildContext context,
    required VoidCallback makeAoOnPressed,
    required VoidCallback saveOnPressed,
    required VoidCallback deleteOnPressed,
    required VoidCallback moveOnPressed,
    required Set<String> itemsName
  }) {
    return BottomTrailing().buildTrailing(
      context: context,
      children: <Widget>[

        const SizedBox(height: 12),

        const BottomSheetBar(),

        BottomTrailingTitle(title: tempData.appBarTitle),

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

          if(WidgetVisibility.setNotVisible(OriginFile.offline))
          ElevatedButton(
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
        
          if(WidgetVisibility.setVisible(OriginFile.home))
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
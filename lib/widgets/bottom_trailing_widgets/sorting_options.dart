import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

class BottomTrailingSorting {

  Future buildTrailing({
    required BuildContext context,
    required VoidCallback sortUploadDateOnPressed,
    required VoidCallback sortItemNameOnPressed,
    required VoidCallback sortDefaultOnPressed
  }) {
    return BottomTrailing().buildTrailing(
      context: context, 
      children: [

        const SizedBox(height: 12),

        const BottomTrailingBar(),

        const BottomTrailingTitle(title: "Sort By"),
        
        const Divider(color: ThemeColor.lightGrey),
      
        if(WidgetVisibility.setNotVisibleList([OriginFile.offline, OriginFile.sharedMe, OriginFile.sharedOther]))
        ElevatedButton(
          onPressed: sortUploadDateOnPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              SizedBox(width: 15.0),
              Text(
                'Upload Date',
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),

        ElevatedButton(
          onPressed: sortItemNameOnPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              SizedBox(width: 15.0),
              Text(
                'Item Name',
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),

        ElevatedButton(
          onPressed: sortDefaultOnPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              SizedBox(width: 15.0),
              Text(
                'Default',
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

      ],
    );
  }

}
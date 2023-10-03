import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BottomTrailingSorting {

  final tempData = GetIt.instance<TempDataProvider>();

  Future buildTrailing({
    required BuildContext context,
    required VoidCallback sortUploadDateOnPressed,
    required VoidCallback sortItemNameOnPressed,
    required VoidCallback sortDefaultOnPressed
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

            const SheetBar(),

            const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.0, top: 25.0),
                child: Text(
                  "Sort By",
                  style: TextStyle(
                    color: ThemeColor.secondaryWhite,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            const Divider(color: ThemeColor.lightGrey),
          
            if(tempData.origin != OriginFile.offline)
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

            if(tempData.origin != OriginFile.public)
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
      },
    );
  }
}
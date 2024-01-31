import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

class BottomTrailingShared {

  Future buildTrailing({
    required BuildContext context,
    required VoidCallback sharedToMeOnPressed,
    required VoidCallback sharedToOthersOnPressed,
  }) {
    return BottomTrailing().buildTrailing(
      context: context, 
      childrens: <Widget>[

        const SizedBox(height: 12),

        const BottomsheetBar(),

        const Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.0, top: 25.0),
            child: Text(
              "Shared",
              style: TextStyle(
                color: ThemeColor.secondaryWhite,
                fontSize: 16,
              ),
            ),
          ),
        ),
        
        const Divider(color: ThemeColor.lightGrey),
          
        ElevatedButton(
          onPressed: sharedToMeOnPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.chevron_right),
              SizedBox(width: 10.0),
              Text(
                'Shared to me',
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),

        ElevatedButton(
          onPressed: sharedToOthersOnPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.chevron_left),
              SizedBox(width: 10.0),
              Text(
                'Shared files',
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
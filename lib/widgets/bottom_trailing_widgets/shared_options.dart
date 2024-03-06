import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
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
      children: [

        const SizedBox(height: 12),

        const BottomTrailingBar(),

        const BottomTrailingTitle(title: "Shared"),
        
        const Divider(color: ThemeColor.lightGrey),
          
        ElevatedButton(
          onPressed: sharedToMeOnPressed,
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              Icon(Icons.chevron_right, color: ThemeColor.secondaryWhite),
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
              Icon(Icons.chevron_left, color: ThemeColor.secondaryWhite),
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
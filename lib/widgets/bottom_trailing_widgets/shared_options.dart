import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

class BottomTrailingShared {

  Widget _buildSharedButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: GlobalsStyle.btnBottomDialogBackgroundStyle,
      child: Row(
        children: [
          Icon(icon, color: ThemeColor.secondaryWhite),
          const SizedBox(width: 10.0),
          Text(
            text,
            style: GlobalsStyle.btnBottomDialogTextStyle,
          ),
        ],
      ),
    );
  }

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
          
        _buildSharedButton(
          text: "Shared to me",
          icon: Icons.chevron_right,
          onPressed: sharedToMeOnPressed
        ),

        _buildSharedButton(
          text: "Shared files",
          icon: Icons.chevron_left,
          onPressed: sharedToOthersOnPressed
        ),

        const SizedBox(height: 20),

      ],
    );
  }
  
}
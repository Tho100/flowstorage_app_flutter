import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

class BottomTrailingPsSearchFilter {

  Widget _buildFilterButton({
    required String text,
    required VoidCallback onPressed,
    required BuildContext context
  }) {
    return ElevatedButton(
      onPressed: () { 
        Navigator.pop(context);
        onPressed(); 
      },
      style: GlobalsStyle.btnBottomDialogBackgroundStyle,
      child: Row(
        children: [
          
          const SizedBox(width: 15.0),

          Text(text,
            style: GlobalsStyle.btnBottomDialogTextStyle
          ),

        ],
      ),
    );
  }

  Future buildBottomTrailing({
    required BuildContext context,
    required VoidCallback onTitlePressed,
    required VoidCallback onUploaderNamePressed,
  }) {
    return BottomTrailing().buildTrailing(
      context: context, 
      children: [

        const SizedBox(height: 12),

        const BottomTrailingBar(),

        const BottomTrailingTitle(title: "Filter Search"),
        
        const Divider(color: ThemeColor.lightGrey),

        _buildFilterButton(
          text: "File title",
          onPressed: onTitlePressed,
          context: context
        ),

        _buildFilterButton(
          text: "Uploader name",
          onPressed: onUploaderNamePressed,
          context: context
        ),

        const SizedBox(height: 20),
        
      ],
    );

  }

}
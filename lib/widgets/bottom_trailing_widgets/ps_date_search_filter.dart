import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

class PsDateSearchFilterBottomTrailing {

  Widget _buildFilterButton({
    required String text,
    required VoidCallback onPressed
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: GlobalsStyle.btnBottomDialogBackgroundStyle,
      child: Row(
        children: [
          const SizedBox(width: 15.0),
          Text(
            text,
            style: GlobalsStyle.btnBottomDialogTextStyle,
          ),
        ],
      ),
    );
  }

  Future buildBottomTrailing({
    required BuildContext context,
    required VoidCallback onPast24HoursPressed,
    required VoidCallback onPastWeekPressed,
    required VoidCallback onPastMonthPressed
  }) {
    return BottomTrailing().buildTrailing(
      context: context, 
      children: [

        const SizedBox(height: 12),

        const BottomTrailingBar(),

        const BottomTrailingTitle(title: "Filter Upload Date"),
        
        const Divider(color: ThemeColor.lightGrey),

        _buildFilterButton(
          text: "Past 24 hours",
          onPressed: () {
            Navigator.pop(context);
            onPast24HoursPressed();
          },
        ),

        _buildFilterButton(
          text: "Past week",
          onPressed: () {
            Navigator.pop(context);
            onPastWeekPressed();
          },
        ),

        _buildFilterButton(
          text: "Past month",
          onPressed: () {
            Navigator.pop(context);
            onPastMonthPressed();
          },
        ),

        const SizedBox(height: 20),
        
      ],
    );
  }
  
}
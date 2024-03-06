import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

class PsDateSearchFilterBottomTrailing {

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

        const Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.0, top: 25.0),
            child: Text(
              "Filter Upload Date",
              style: TextStyle(
                color: ThemeColor.secondaryWhite,
                fontSize: 16,
              ),
            ),
          ),
        ),
        
        const Divider(color: ThemeColor.lightGrey),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onPast24HoursPressed();
          },
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              SizedBox(width: 15.0),
              Text(
                'Past 24 hours',
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onPastWeekPressed();
          },
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              SizedBox(width: 15.0),
              Text(
                'Past week',
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),

        ElevatedButton(
          onPressed: () { 
            Navigator.pop(context);
            onPastMonthPressed();
          },
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              SizedBox(width: 15.0),
              Text('Past month',
                style: GlobalsStyle.btnBottomDialogTextStyle
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
        
      ],
    );

  }
}
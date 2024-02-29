import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_widgets/ps_date_search_filter.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

class BottomTrailingPsSearchFilter {

  Future buildBottomTrailing({
    required BuildContext context,
    required VoidCallback onTitlePressed,
    required VoidCallback onUploaderNamePressed,
    required VoidCallback onPast24HoursPressed,
    required VoidCallback onPastWeekPressed,
    required VoidCallback onPastMonthPressed,
  }) {
    return BottomTrailing().buildTrailing(
      context: context, 
      children: [

        const SizedBox(height: 12),

        const BottomSheetBar(),

        const Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.0, top: 25.0),
            child: Text(
              "Filter Search",
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
            onTitlePressed();
          },
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              SizedBox(width: 15.0),
              Text(
                'File title',
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            PsDateSearchFilterBottomTrailing().buildBottomTrailing(
              context: context,
              onPast24HoursPressed: onPast24HoursPressed,
              onPastWeekPressed: onPastWeekPressed,
              onPastMonthPressed: onPastMonthPressed
            );
          },
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              SizedBox(width: 15.0),
              Text(
                'Upload date',
                style: GlobalsStyle.btnBottomDialogTextStyle,
              ),
            ],
          ),
        ),

        ElevatedButton(
          onPressed: () { 
            Navigator.pop(context);
            onUploaderNamePressed(); 
          },
          style: GlobalsStyle.btnBottomDialogBackgroundStyle,
          child: const Row(
            children: [
              SizedBox(width: 15.0),
              Text('Uploader name',
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
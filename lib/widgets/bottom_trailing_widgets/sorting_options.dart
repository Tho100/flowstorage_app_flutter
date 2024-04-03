import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

class BottomTrailingSorting {

  Widget _buildSortButton({
    required VoidCallback onPressed,
    required String sortType,
    required Widget icon,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: GlobalsStyle.btnBottomDialogBackgroundStyle,
      child: Row(
        children: [
          icon,
          const SizedBox(width: 15.0),
          Text(
            label,
            style: GlobalsStyle.btnBottomDialogTextStyle,
          ),
        ],
      ),
    );
  }

  Future buildTrailing({
    required BuildContext context,
    required VoidCallback sortUploadDateOnPressed,
    required VoidCallback sortItemNameOnPressed,
    required VoidCallback sortDefaultOnPressed,
    required String sortType,
    required bool isDateAscending,
    required bool isNameAscending,
  }) {
    return BottomTrailing().buildTrailing(
      context: context,
      children: [

        const SizedBox(height: 12),

        const BottomTrailingBar(),

        const BottomTrailingTitle(title: "Sort By"),

        const Divider(color: ThemeColor.lightGrey),

        if (WidgetVisibility.setNotVisibleList([OriginFile.offline, OriginFile.sharedMe, OriginFile.sharedOther]))
          _buildSortButton(
            onPressed: sortUploadDateOnPressed,
            sortType: sortType,
            icon: sortType == "Upload Date"
              ? isNameAscending
                ? const Icon(Icons.keyboard_arrow_up, color: ThemeColor.secondaryWhite)
                : const Icon(Icons.keyboard_arrow_down, color: ThemeColor.secondaryWhite)
              : const SizedBox(width: 25.0),
            label: 'Upload Date',
          ),

        _buildSortButton(
          onPressed: sortItemNameOnPressed,
          sortType: sortType,
          icon: sortType == "Item Name"
            ? isNameAscending
              ? const Icon(Icons.keyboard_arrow_up, color: ThemeColor.secondaryWhite)
              : const Icon(Icons.keyboard_arrow_down, color: ThemeColor.secondaryWhite)
            : const SizedBox(width: 25.0),
          label: 'Item Name',
        ),

        _buildSortButton(
          onPressed: sortDefaultOnPressed,
          sortType: sortType,
          icon: sortType == "Default"
            ? const Icon(Icons.keyboard_arrow_down, color: ThemeColor.secondaryWhite)
            : const SizedBox(width: 25.0),
          label: 'Default',
        ),

        const SizedBox(height: 20),

      ],
    );
  }

}
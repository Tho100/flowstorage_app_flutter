import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/helper/visibility_checker.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BottomTrailingSelectedItems {

  final tempData = GetIt.instance<TempDataProvider>();

  Widget _buildOptionButton({
    required String text,
    required IconData icon,
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
          Icon(icon, color: ThemeColor.secondaryWhite),
          const SizedBox(width: 15.0),
          Text(text,
            style: GlobalsStyle.btnBottomDialogTextStyle
          ),
        ],
      ),
    );
  }

  Future buildTrailing({
    required BuildContext context,
    required VoidCallback makeAoOnPressed,
    required VoidCallback saveOnPressed,
    required VoidCallback deleteOnPressed,
    required VoidCallback moveOnPressed,
    required Set<String> itemsName
  }) {
    return BottomTrailing().buildTrailing(
      context: context,
      children: [

        const SizedBox(height: 12),

        const BottomTrailingBar(),

        BottomTrailingTitle(title: tempData.appBarTitle),

        const Divider(color: ThemeColor.lightGrey),
        
        if(itemsName.every((name) => name.contains('.'))) ... [

          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              saveOnPressed();
            },
            style: GlobalsStyle.btnBottomDialogBackgroundStyle,
            child: const Row(
              children: [
                Icon(Icons.file_download_outlined, color: ThemeColor.secondaryWhite),
                SizedBox(width: 15.0),
                Text(
                  'Save to device',
                  style: GlobalsStyle.btnBottomDialogTextStyle,
                ),
              ],
            ),
          ),

          if(WidgetVisibility.setNotVisible(OriginFile.offline))
          _buildOptionButton(
            text: "Make available offline", 
            icon: Icons.offline_bolt_outlined, 
            onPressed: makeAoOnPressed, 
            context: context
          ),
        
          if(WidgetVisibility.setVisible(OriginFile.home))
          _buildOptionButton(
            text: "Move", 
            icon: Icons.open_with_outlined, 
            onPressed: moveOnPressed, 
            context: context
          ),

          const Divider(color: ThemeColor.lightGrey),

          _buildOptionButton(
            text: "Delete", 
            icon: Icons.delete_outline, 
            onPressed: deleteOnPressed, 
            context: context
          ),

        ],

        const SizedBox(height: 12),

      ],
    );

  }
}
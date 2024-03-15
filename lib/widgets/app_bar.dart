import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/material.dart';

class CustomAppBar {

  final String title;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final BuildContext? context;
  final VoidCallback? customBackOnPressed;

  const CustomAppBar({
    required this.context,
    required this.title,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.customBackOnPressed
  });

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: GlobalsStyle.appBarTextStyle
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: customBackOnPressed ?? () => Navigator.pop(context!),
      ),
      backgroundColor: backgroundColor ?? ThemeColor.darkBlack,
      elevation: 0,
      actions: actions,
      bottom: bottom,
    );
  }

}
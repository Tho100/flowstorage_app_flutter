import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class CustomAppBar {

  final String title;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final BuildContext? context;
  final VoidCallback? customBackOnPressed;
  final Widget? customLeading;

  const CustomAppBar({
    required this.context,
    required this.title,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.customBackOnPressed,
    this.customLeading
  });

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      titleSpacing: 5,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
          color: Color.fromARGB(255,236,236,236),
          fontWeight: FontWeight.w600,
          fontSize: 19,          
        ),
      ),
      leading: customLeading ?? IconButton(
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
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar {

  final String title;
  final Color? backgroundColor;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final BuildContext? context;
  final VoidCallback? customBackOnPressed;
  final Widget? customLeading;
  final bool? enableCenter;
  final Color? leadingColor;

  const CustomAppBar({
    required this.context,
    required this.title,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.customBackOnPressed,
    this.customLeading,
    this.enableCenter,
    this.leadingColor,
  });

  PreferredSizeWidget? buildAppBar() {
    return AppBar(
      titleSpacing: 5,
      centerTitle: enableCenter ?? true,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: const Color.fromARGB(255, 245, 245, 245),
          fontWeight: FontWeight.w800,
          fontSize: 18,          
        ),
      ),
      leading: customLeading ?? IconButton(
        icon: Icon(CupertinoIcons.chevron_back, color: leadingColor ?? ThemeColor.justWhite),
        onPressed: customBackOnPressed ?? () => Navigator.pop(context!),
      ),
      backgroundColor: backgroundColor ?? ThemeColor.darkBlack,
      elevation: 0,
      actions: actions,
      bottom: bottom,
    );
  }

}
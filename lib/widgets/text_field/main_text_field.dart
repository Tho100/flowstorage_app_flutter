import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainTextField extends StatelessWidget {

  final String hintText;
  final int? maxLength;
  final int? maxLines;
  final bool? autoFocus;
  final TextEditingController controller;
  
  const MainTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.maxLength,
    this.maxLines,
    this.autoFocus,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: GoogleFonts.inter(
        color: ThemeColor.secondaryWhite,
        fontWeight: FontWeight.w700,
      ),
      autofocus: autoFocus ?? false,
      enabled: true,
      maxLines: maxLines,
      maxLength: maxLength,
      controller: controller,
      decoration: GlobalsStyle.setupTextFieldDecoration(hintText),
    );
  }

}
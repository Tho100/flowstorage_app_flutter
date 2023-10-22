import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/material.dart';

class MainTextField extends StatelessWidget {

  final String hintText;
  final int? maxLength;
  final TextEditingController controller;
  
  const MainTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.maxLength
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: ThemeColor.secondaryWhite),
      enabled: true,
      maxLength: maxLength,
      controller: controller,
      decoration: GlobalsStyle.setupTextFieldDecoration(hintText),
    );
  }

}
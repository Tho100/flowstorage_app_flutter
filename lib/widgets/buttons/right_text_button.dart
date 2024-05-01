import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RightTextButton extends StatelessWidget {

  final VoidCallback onPressed;
  final String text;

  const RightTextButton({
    super.key,
    required this.text,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text,
        style: GoogleFonts.inter(
          color: ThemeColor.darkPurple,
          fontSize: 14.2,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
  
}
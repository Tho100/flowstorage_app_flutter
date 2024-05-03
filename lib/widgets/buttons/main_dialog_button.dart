import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainDialogButton extends StatelessWidget {

  final String text;
  final VoidCallback onPressed;
  final bool isButtonClose;

  const MainDialogButton({
    super.key, 
    required this.text,
    required this.onPressed,
    required this.isButtonClose
  });

  Widget buildCloseButton() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 2), 
        backgroundColor: ThemeColor.mediumBlack,
        elevation: 0,
      ),
      child: Text(text,
        style: GoogleFonts.inter(
          fontSize: 15, 
          fontWeight: FontWeight.w800,
          color: ThemeColor.secondaryWhite
        )
      ),
    );
  }

  Widget buildDefaultButton() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 5), 
        backgroundColor: ThemeColor.mediumBlack,
        elevation: 0,
      ),
      child: Text(text,
        style: GoogleFonts.inter(
          fontSize: 15, 
          color: ThemeColor.darkPurple, 
          fontWeight: FontWeight.w800
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isButtonClose 
    ? buildCloseButton() : buildDefaultButton();
  }
  
}
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

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
        style: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold,
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
        style: const TextStyle(
          fontSize: 16, 
          color: ThemeColor.darkPurple, 
          fontWeight: FontWeight.bold
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
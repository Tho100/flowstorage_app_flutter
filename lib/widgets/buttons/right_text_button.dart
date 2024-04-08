import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

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
        style: const TextStyle(
          color: ThemeColor.darkPurple,
          fontSize: 15.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
}
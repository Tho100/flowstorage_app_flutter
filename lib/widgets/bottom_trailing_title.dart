import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomTrailingTitle extends StatelessWidget {

  final String title;

  const BottomTrailingTitle({
    required this.title,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0, top: 25.0),
        child: Text(
          title,
          style: GoogleFonts.inter(
            color: ThemeColor.secondaryWhite,
            fontSize: 18.2,
            fontWeight: FontWeight.w800
          ),
        ),
      ),
    );
  }

}
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderText extends StatelessWidget {

  final String title;
  final String subTitle;

  const HeaderText({
    super.key,
    required this.title,
    required this.subTitle
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          const SizedBox(height: 15),
    
          Text(
            title,
            style: GoogleFonts.poppins(
              color: ThemeColor.darkPurple,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
    
          const SizedBox(height: 12),
          
          Text(
           subTitle,
            style: GoogleFonts.poppins(
              color: ThemeColor.secondaryWhite, 
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),

        ],
      ),
    );
  }

}
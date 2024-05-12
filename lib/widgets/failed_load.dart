import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FailedLoad extends StatelessWidget {
  
  const FailedLoad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            
            const SizedBox(height: 25),

            Text(
            'An error occurred',
              style: GoogleFonts.inter(
                color: ThemeColor.darkPurple,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
    
            const SizedBox(height: 10),
    
            Text(
            'Failed to load this file',
              style: GoogleFonts.inter(
                color: const Color.fromARGB(255, 195, 195, 195),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),

          ],
        ),
      ),
    );
  }

}
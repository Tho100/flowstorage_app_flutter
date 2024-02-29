import 'dart:typed_data';
import 'dart:ui';

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityImagePreviewer {

  static Future showPreviewer(String fileName, Uint8List? imageBytes) {

    final fileType = fileName.split('.').last;

    return showDialog(
      barrierDismissible: true,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 8.0, sigmaX: 8.0),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            ),
            backgroundColor: ThemeColor.darkBlack.withOpacity(0.8),
            content: SizedBox( 
              width: MediaQuery.of(context).size.width*2,
              height: 285,
              child: Center(
                child: Column(
                  children: [
                    Text(fileName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
        
                    const SizedBox(height: 15),
        
                    Container(
                      width: MediaQuery.of(context).size.width*2,
                      height: 245,
                      decoration: BoxDecoration(
                        color: ThemeColor.mediumGrey,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(imageBytes!,
                          fit: Globals.generalFileTypes.contains(fileType) 
                          ? BoxFit.scaleDown : BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ),
        );
      },
    );
  }
  
}
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/alert_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomFormDialog {

  static Future startDialog(String headMessage, String subMessage) {
    return showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialogWidget(
          content: SizedBox( 
            width: MediaQuery.of(context).size.width*4,
            height: 250,
            child: Center(
              child: Column(
                children: [
                  
                  Text(headMessage,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 23,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  Text(subMessage,
                    style: GoogleFonts.inter(
                      color: Colors.grey,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),
                  
                  SizedBox(
                    width: 285,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: ThemeColor.mediumBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close',
                        style: GoogleFonts.inter(
                          color: ThemeColor.darkPurple,
                          fontSize: 17,
                          fontWeight: FontWeight.w800
                        ),
                      ),
                    ),
                  ),
            
                ],
              ),
            ),
          )
        );
      },
    );
  }

}
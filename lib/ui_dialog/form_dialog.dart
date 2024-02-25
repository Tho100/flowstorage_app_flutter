import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class CustomFormDialog {

  static Future startDialog(String headMessage, String subMessage) {
    return showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)
          ),
          backgroundColor: ThemeColor.mediumBlack,
          content: SizedBox( 
            width: MediaQuery.of(context).size.width*4,
            height: 250,
            child: Center(
              child: Column(
                children: [
                  Text(headMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 15),

                  Text(subMessage,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
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
                        )
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close',
                        style: TextStyle(
                          color: ThemeColor.darkPurple,
                          fontSize: 18,
                          fontWeight: FontWeight.w600
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
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlobalsStyle {

  static const dotSeparator = " \u{2022} ";

  static final psTagsToColor = {
    "Entertainment": Colors.orange,
    "Creativity": const Color.fromARGB(255, 138, 43, 226),
    "Data": const Color.fromARGB(255, 0, 206, 209),
    "Gaming": Colors.green,
    "Software": Colors.blue,
    "Education": Colors.redAccent,
    "Music": Colors.deepOrangeAccent,
    "Random": Colors.grey,
  };

  static final psTagsColor = {
    Colors.orange,
    const Color.fromARGB(255, 138, 43, 226),
    const Color.fromARGB(255, 0, 206, 209),
    Colors.green,
    Colors.blue,
    Colors.redAccent,
    Colors.deepOrangeAccent,
    Colors.grey,
  };

  static final tabBarTextStyle = GoogleFonts.inter(
    fontSize: 13, fontWeight: FontWeight.w800
  );

  static final settingsLeftTextStyle = GoogleFonts.inter(
    color: ThemeColor.secondaryWhite,
    fontWeight: FontWeight.w800,
    fontSize: 16,
  );

  static final btnBottomDialogTextStyle = GoogleFonts.inter(
    color: const Color.fromARGB(255,235,235,235),
    fontWeight: FontWeight.w800,
    fontSize: 16,
  ); 

  static final btnBottomDialogBackgroundStyle = ElevatedButton.styleFrom(
    backgroundColor: ThemeColor.darkBlack,
    elevation: 0,
    minimumSize: const Size(double.infinity, 55),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero, 
    ),
  );

  static const bottomDialogBorderStyle = RoundedRectangleBorder( 
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18)
    )
  );

  static final btnMainStyle = ElevatedButton.styleFrom(
    backgroundColor: ThemeColor.darkPurple,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  );

  static final btnMiniStyle = ElevatedButton.styleFrom(
    backgroundColor: ThemeColor.darkGrey,
    elevation: 0,
    shape: const StadiumBorder(),
  );

  static InputDecoration setupTextFieldDecoration(String hintText, {IconButton? customSuffix, TextStyle? customCounterStyle, }) {
    return InputDecoration(
      hintText: hintText,
      suffixIcon: customSuffix,
      counterText: '',
      counterStyle: customCounterStyle,
      contentPadding: const EdgeInsets.fromLTRB(20.0, 22.0, 10.0, 25.0),
      hintStyle: const TextStyle(color: Color.fromARGB(255, 197, 197, 197)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: ThemeColor.lightGrey,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          width: 2.0,
          color: Color.fromARGB(255, 6, 102, 226),
        ),
      ),
    );
  }
  
  static InputDecoration setupPasscodeFieldDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: const BorderSide(
          color: ThemeColor.darkPurple,
          width: 2.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          width: 2.5,
          color: ThemeColor.darkPurple,
        ),
      ),
    );
  }

}
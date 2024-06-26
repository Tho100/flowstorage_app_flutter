import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextField {

  final MediaQueryData mediaQuery;

  const AuthTextField(this.mediaQuery);

  Widget pinTextField({
    required TextEditingController controller,
    double? customWidth
  }) {
    return SizedBox(
      width: customWidth ?? mediaQuery.size.width*0.2,
      child: TextFormField(
        style: GoogleFonts.inter(
          color: ThemeColor.secondaryWhite,
          fontWeight: FontWeight.w700,
        ),
        controller: controller,
        obscureText: true,
        maxLength: 3,
        keyboardType: TextInputType.number,
        decoration: GlobalsStyle.setupTextFieldDecoration(
          "PIN",
          customCounterStyle: const TextStyle(color: Color.fromARGB(255,199,199,199)),
        ),
      ),
    );
  }

  Widget passwordTextField({
    required TextEditingController controller,
    required ValueNotifier<bool> visibility,
    double? customWidth,
    String? customText,    
  }) {
    return SizedBox(
      width: customWidth ?? mediaQuery.size.width*0.68,
      child: ValueListenableBuilder(
        valueListenable: visibility,
        builder: (context, value, child) {
          return TextFormField(
            style: GoogleFonts.inter(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w700,
            ),
            controller: controller,
            obscureText: !value,
            decoration: GlobalsStyle.setupTextFieldDecoration(
              customText ?? "Enter a password",
              customSuffix: IconButton(
                icon: Icon(value ? Icons.visibility : Icons.visibility_off,
                  color: ThemeColor.thirdWhite,
                ), 
                onPressed: () => visibility.value = !visibility.value,
              ),
            ),
          );
        },
      ),
    );
  }

}
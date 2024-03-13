import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/material.dart';

class AuthTextField {

  final MediaQueryData mediaQuery;

  const AuthTextField(this.mediaQuery);

  Widget pinTextField({required TextEditingController controller}) {
    return SizedBox(
      width: mediaQuery.size.width*0.2,
      child: TextFormField(
        style: const TextStyle(
          color: ThemeColor.secondaryWhite,
          fontWeight: FontWeight.w500,
        ),
        enabled: true,
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
    required ValueNotifier<bool> visibility
  }) {
    return SizedBox(
      width: mediaQuery.size.width*0.68,
      child: ValueListenableBuilder(
        valueListenable: visibility,
        builder: (context, value, child) {
          return TextFormField(
            style: const TextStyle(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w500,
            ),
            enabled: true,
            controller: controller,
            obscureText: !value,
            decoration: GlobalsStyle.setupTextFieldDecoration(
              "Enter a password",
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
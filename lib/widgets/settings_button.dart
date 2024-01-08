import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {

  final String topText;
  final String bottomText;
  final VoidCallback onPressed;

  const SettingsButton({
    required this.topText,
    required this.bottomText,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            
                  const SizedBox(height: 5),
            
                  Text(
                    topText,
                    style: GlobalsStyle.settingsLeftTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 305,
                    child: Text(
                      bottomText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: ThemeColor.thirdWhite
                      ),
                    ),
                  ),
            
                  const SizedBox(height: 15),
            
                ],
              ),
            ),
          ),
        ),
      ],
      
    );
  }
}
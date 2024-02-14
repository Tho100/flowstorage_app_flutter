import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {

  final String topText;
  final String bottomText;
  final VoidCallback onPressed;

  final bool? hideCaret;

  const SettingsButton({
    required this.topText,
    required this.bottomText,
    required this.onPressed,
    this.hideCaret = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            
                  const SizedBox(height: 10),
            
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        topText,
                        style: GlobalsStyle.settingsLeftTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      if(!hideCaret!)
                      Transform.translate(
                        offset: const Offset(0, 10),
                        child: const Icon(Icons.arrow_forward_ios, color: ThemeColor.thirdWhite, size: 20,)
                      ),
                      const SizedBox(width: 25),
                    ],
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
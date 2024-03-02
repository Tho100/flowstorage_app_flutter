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
            
                  SizedBox(height: hideCaret! ? 10 : 5),
            
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
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ThemeColor.darkGrey.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward_ios, color: ThemeColor.thirdWhite, size: 20)
                        )
                      ),
                      const SizedBox(width: 25),
                    ],
                  ),
                  
                  Transform.translate(
                    offset: Offset(0, hideCaret! ? 4 : -4),
                    child: SizedBox(
                      width: 305,
                      child: Text(
                        bottomText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ThemeColor.thirdWhite
                        ),
                      ),
                    ),
                  ),
            
                  SizedBox(height: hideCaret! ? 15 : 10),
            
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
}
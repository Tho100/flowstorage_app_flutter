import 'dart:typed_data';

import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {

  final Color? customBackgroundColor;
  final double? customHeight;
  final double? customWidth;

  final Widget? customOnEmpty;
  final ValueNotifier<Uint8List?>? notifierValue;

  const ProfilePicture({
    required this.notifierValue,
    this.customOnEmpty,
    this.customHeight,
    this.customWidth,
    this.customBackgroundColor,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: customWidth ?? 55,
      height: customHeight ?? 55,
      decoration: BoxDecoration(
        color: customBackgroundColor ?? ThemeColor.darkGrey,
        shape: BoxShape.circle,
      ),
      child: ValueListenableBuilder(
        valueListenable: notifierValue!,
        builder: (context, imageBytes, child) {
          return imageBytes!.isEmpty 
          ? customOnEmpty ?? const Center(
            child: Icon(
              Icons.photo_camera_rounded, 
              color: ThemeColor.secondaryWhite
            ),
          )
          : ClipOval(
            child: Image.memory(
              imageBytes,
              fit: BoxFit.cover,
            ),
          );
        }
      ),
    );
  }
  
}
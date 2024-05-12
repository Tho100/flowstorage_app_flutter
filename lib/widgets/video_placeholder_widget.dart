import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class VideoPlaceholderWidget extends StatelessWidget {

  final double customWidth;
  final double customHeight;
  final double customIconSize;

  const VideoPlaceholderWidget({
    this.customWidth = 32,
    this.customHeight = 32,
    this.customIconSize = 22,
    Key? key  
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: customWidth,
      height: customHeight,
      decoration: BoxDecoration(
        color: ThemeColor.mediumGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: customIconSize)
    );
  }
  
}
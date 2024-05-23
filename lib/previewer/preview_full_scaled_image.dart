import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PreviewFullScaledImage extends StatelessWidget {

  final Uint8List? imageBytes;

  const PreviewFullScaledImage({
    required this.imageBytes,
    Key? key
  }) : super(key: key);

  void toggleSystemUI() {
      SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, 
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        toggleSystemUI();
        return true;
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            toggleSystemUI();
            Navigator.pop(context);
          },
          child: InteractiveViewer(
            child: Center(
              child: Image.memory(
                imageBytes!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

}

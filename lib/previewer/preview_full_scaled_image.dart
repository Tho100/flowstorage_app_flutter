import 'dart:typed_data';

import 'package:flowstorage_fsc/models/system_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PreviewFullScaledImage extends StatelessWidget {

  final Uint8List? imageBytes;

  const PreviewFullScaledImage({
    required this.imageBytes,
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemToggle().toggleStatusBarVisibility(true);
        return true;
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            SystemToggle().toggleStatusBarVisibility(true);
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

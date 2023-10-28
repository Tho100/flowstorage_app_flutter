import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {

  const LoadingIndicator({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ThemeColor.darkPurple),
      ),
    );
  }

}
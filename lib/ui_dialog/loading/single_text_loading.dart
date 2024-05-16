import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/alert_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SingleTextLoading {

  late String title;
  late BuildContext context;
  
  Future<void> startLoading({
    required String title,
    required BuildContext context
  }) {

    this.title = title;
    this.context = context;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _buildLoadingDialog(),
    );
  }

  void stopLoading() {
    Navigator.pop(context);
  }

  AlertDialogWidget _buildLoadingDialog() {
    
    const color = ThemeColor.darkPurple;

    return AlertDialogWidget(
      title: Row(
        children: [

          const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(color: color),
          ),

          const SizedBox(width: 25),

          Text(title,
            style: GoogleFonts.inter(
              color: ThemeColor.justWhite,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 25),

        ]
      ),
    );
  }

}
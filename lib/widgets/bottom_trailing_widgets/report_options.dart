import 'package:flowstorage_fsc/pages/public_storage/submit_report_page.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomTrailingReport {

  final BuildContext context;
  final String fileName;

  BottomTrailingReport({
    required this.context, 
    required this.fileName
  });

  Widget _buildReportTypeButtons(
    String reportName, 
    String reportType,
  ) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: () { 
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SubmitReportPage(fileName: fileName, reportType: reportType))
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeColor.darkBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35.0),
            side: const BorderSide(color: ThemeColor.lightGrey),
          ),
        ),
        child: Text(reportName,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800
          ),
        ),
      ),
    );
  }

  Future buildReportType() {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkBlack,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: 270,
          child: Column(
            children: [

              const SizedBox(height: 12),

              const BottomTrailingBar(),

              const BottomTrailingTitle(title: "Submit a Report"),
              
              const Divider(color: ThemeColor.lightGrey),
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                        
                    Column(
              
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
              
                      children: [
              
                        const SizedBox(height: 5),
              
                        Row(
                          children: [

                            _buildReportTypeButtons("Copyright violation", "cv"),

                          ],
                        ),
              
                        const SizedBox(height: 10),

                        Row(
      
                          children: [

                          _buildReportTypeButtons("Trademark violation", "tv"),
              
                          const SizedBox(width: 8),
              
                          _buildReportTypeButtons("Spam", "sp"),
              
                        ],
                      ),

                        const SizedBox(height: 10),

                        Row(
                          children: [

                            _buildReportTypeButtons("Malware", "ma"),
                            
                            const SizedBox(width: 8),
                            
                            _buildReportTypeButtons("Privacy violation", "pv"),

                          ],
                        ),

                      ],
                    ),    
                  ],
              
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
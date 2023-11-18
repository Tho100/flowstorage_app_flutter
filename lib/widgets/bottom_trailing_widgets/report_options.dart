import 'package:flowstorage_fsc/pages/public_storage/submit_report_page.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BottomTrailingReport {

  final BuildContext context;
  final String fileName;

  BottomTrailingReport({
    required this.context, 
    required this.fileName
  });

  final tempData = GetIt.instance<TempDataProvider>();

  Widget _buildReportTypeButtons(
    String reportName, 
    String reportType,
  ) {
    return ElevatedButton(
      onPressed: () { 
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) 
          => SubmitReportPage(fileName: fileName, reportType: reportType))
        );
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: ThemeColor.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0),
          side: const BorderSide(color: ThemeColor.whiteGrey),
        ),
      ),
      child: Text(reportName),
    );
  }

  Future buildReportType() {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [

              const SizedBox(height: 12),

              const BottomsheetBar(),

              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.0, top: 25.0),
                  child: Text(
                    "Submit a Report",
                    style: TextStyle(
                      color: ThemeColor.secondaryWhite,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
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

                            const SizedBox(width: 8),

                            _buildReportTypeButtons("Malware", "ma"),

                          ],
                        ),
              
                        const SizedBox(height: 3),

                        Row(
      
                          children: [

                          _buildReportTypeButtons("Trademark violation", "tv"),
              
                          const SizedBox(width: 8),
              
                          _buildReportTypeButtons("Prviacy violation", "pv"),
              
                          const SizedBox(width: 8),
              
                          _buildReportTypeButtons("Spam", "sp"),
              
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
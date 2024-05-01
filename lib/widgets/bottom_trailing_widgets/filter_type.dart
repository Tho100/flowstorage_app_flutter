import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomTrailingFilter {

  final BuildContext context;
  final Function filterTypeFunctionality;

  BottomTrailingFilter({
    required this.context,
    required this.filterTypeFunctionality
  });

  static String _joinFileTypes(Set<String> fileTypes) {
    return fileTypes.map((type) => '.$type').join(',');
  }

  final imageTypes = _joinFileTypes(Globals.imageType);
  final videoTypes = _joinFileTypes(Globals.videoType);
  final textTypes = _joinFileTypes(Globals.textType);
  final audioTypes = _joinFileTypes(Globals.audioType);
  final excelTypes = "${_joinFileTypes(Globals.excelType)},.csv";
  final docTypes = _joinFileTypes(Globals.wordType);

  Widget _buildFilterTypeButtons(
    String filterName, 
    IconData icon, 
    String filterType,
    {double? customWidth}
  ) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 42,
      ),
      child: ElevatedButton(
        onPressed: () {
          filterTypeFunctionality(filterType);  
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          fixedSize: Size.fromWidth(customWidth ?? 112),
          backgroundColor: ThemeColor.darkBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35.0),
            side: const BorderSide(color: ThemeColor.lightGrey),
          ),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(filterName,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              )
            ),
          ],
        ),
      ),
    );
  }

  Future buildFilterTypeAll() {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkBlack,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: 345,
          child: Column(
            children: [

              const SizedBox(height: 12),

              const BottomTrailingBar(),

              const BottomTrailingTitle(title: "Filter Type"),
              
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
              
                        _buildFilterTypeButtons("Images", Icons.photo_outlined, imageTypes),
              
                        const SizedBox(height: 3),

                        Row(
      
                          children: [

                          _buildFilterTypeButtons("Text", CupertinoIcons.doc_text, textTypes),
              
                          const SizedBox(width: 8),
              
                          _buildFilterTypeButtons("Audio", CupertinoIcons.waveform, audioTypes),
              
                          const SizedBox(width: 8),
              
                          _buildFilterTypeButtons("Videos", CupertinoIcons.video_camera, videoTypes),
              
                        ],
                      ),
                      ],
                    ),
                      
                    const SizedBox(height: 8),
                      
                    Column(
              
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
              
                      children: [
              
                        const SizedBox(height: 8),
              
                        Row(
                          children: [

                            _buildFilterTypeButtons("PDFs", CupertinoIcons.doc, '.pdf'),

                            const SizedBox(width: 8),

                            _buildFilterTypeButtons("Spreadsheets", CupertinoIcons.chart_bar_square, excelTypes, customWidth: 152),

                          ]
                        ),
              
                        const SizedBox(height: 3),

                        Row(
              
                          children: [
              
                            _buildFilterTypeButtons("Documents", CupertinoIcons.doc, docTypes, customWidth: 140),
                                
                            const SizedBox(width: 8),

                            _buildFilterTypeButtons("All", CupertinoIcons.square_on_circle, ' '),
                                    
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

  Future buildFilterTypePhotos() {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkBlack,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: 170,
          child: Column(
            children: [

              const SizedBox(height: 12),

              const BottomTrailingBar(),

              const BottomTrailingTitle(title: "Filter Type"),

              const Divider(color: ThemeColor.lightGrey),
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    _buildFilterTypeButtons("Images", Icons.photo_outlined, imageTypes),
                    const SizedBox(width: 8),

                    _buildFilterTypeButtons("Videos", CupertinoIcons.video_camera, videoTypes),

                    const SizedBox(width: 8),
                    _buildFilterTypeButtons("All", CupertinoIcons.square_on_circle, '.png,.jpg,.jpeg,.mp4,.avi,.mov,.wmv'),
          
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
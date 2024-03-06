import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/bottom_trailing_title.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

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
  final excelTypes = _joinFileTypes(Globals.excelType);
  final docTypes = _joinFileTypes(Globals.wordType);

  Widget _buildFilterTypeButtons(
    String filterName, 
    IconData icon, 
    String filterType,
  ) {
    return ElevatedButton(
      onPressed: () {
        filterTypeFunctionality(filterType);  
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        elevation: 0,
        fixedSize: const Size(112,42),
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
            style: const TextStyle(
              fontWeight: FontWeight.w600
            )
          ),
        ],
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
              
                        _buildFilterTypeButtons("Images", Icons.photo, imageTypes),
              
                        const SizedBox(height: 3),

                        Row(
      
                          children: [

                          _buildFilterTypeButtons("Text", Icons.text_snippet_rounded, textTypes),
              
                          const SizedBox(width: 8),
              
                          _buildFilterTypeButtons("Audio", Icons.music_note_rounded, audioTypes),
              
                          const SizedBox(width: 8),
              
                          _buildFilterTypeButtons("Videos", Icons.video_collection_rounded, videoTypes),
              
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

                            _buildFilterTypeButtons("PDFs", Icons.picture_as_pdf, '.pdf'),
                            const SizedBox(width: 8),
                            _buildFilterTypeButtons("Sheets", Icons.table_chart, excelTypes),

                          ]
                        ),
              
                        const SizedBox(height: 3),

                        Row(
              
                          children: [
              
                            _buildFilterTypeButtons("DOCs", Icons.text_snippet_outlined, docTypes),
              
                            const SizedBox(width: 8),
              
                            _buildFilterTypeButtons("CSV", Icons.insert_chart_outlined, '.csv'),
                  
                            const SizedBox(width: 8),

                            _buildFilterTypeButtons("All", Icons.shape_line_rounded,' '),
                                    
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
                    
                    _buildFilterTypeButtons("Images", Icons.photo, imageTypes),
                    const SizedBox(width: 8),

                    _buildFilterTypeButtons("Videos", Icons.video_collection_rounded, videoTypes),

                    const SizedBox(width: 8),
                    _buildFilterTypeButtons("All", Icons.shape_line_rounded, '.png,.jpg,.jpeg,.mp4,.avi,.mov,.wmv'),
          
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
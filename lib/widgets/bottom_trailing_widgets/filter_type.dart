import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';

class BottomTrailingFilter {

  final BuildContext context;
  final Function filterTypeFunctionality;

  BottomTrailingFilter({
    required this.context,
    required this.filterTypeFunctionality
  });

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
        backgroundColor: ThemeColor.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0),
          side: const BorderSide(color: ThemeColor.whiteGrey),
        ),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(filterName),
        ],
      ),
    );
  }

  Future buildFilterTypeAll() {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: 345,
          child: Column(
            children: [

              const SizedBox(height: 12),

              const BottomsheetBar(),

              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.0, top: 25.0),
                  child: Text(
                    "Filter Type",
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
              
                        _buildFilterTypeButtons("Images", Icons.photo, '.png,.jpg,.jpeg'),
              
                        const SizedBox(height: 3),

                        Row(
      
                          children: [

                          _buildFilterTypeButtons("Text", Icons.text_snippet_rounded, '.txt,.html'),
              
                          const SizedBox(width: 8),
              
                          _buildFilterTypeButtons("Audio", Icons.music_note_rounded, '.mp3,.wav'),
              
                          const SizedBox(width: 8),
              
                          _buildFilterTypeButtons("Videos", Icons.video_collection_rounded, '.mp4,.avi,.mov,.wmv'),
              
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
                            _buildFilterTypeButtons("Sheets", Icons.table_chart, '.xls,.xlsx'),

                          ]
                        ),
              
                        const SizedBox(height: 3),

                        Row(
              
                          children: [
              
                            _buildFilterTypeButtons("DOCs", Icons.text_snippet_outlined, '.docx,.doc'),
              
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

  Future buildFilterTypePhotos(bool isFromStaggered) {
    return showModalBottomSheet(
      backgroundColor: ThemeColor.darkGrey,
      context: context,
      shape: GlobalsStyle.bottomDialogBorderStyle,
      builder: (context) {
        return SizedBox(
          height: 170,
          child: Column(
            children: [

              const SizedBox(height: 12),

              const BottomsheetBar(),

              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 12.0, top: 25.0),
                  child: Text(
                    "Filter Type",
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    _buildFilterTypeButtons("Images", Icons.photo, '.png,.jpg,.jpeg'),
                    const SizedBox(width: 8),
                    _buildFilterTypeButtons("Videos", Icons.video_collection_rounded, '.mp4,.avi,.mov,.wmv'),
                    const SizedBox(width: 8),
                    _buildFilterTypeButtons("All", Icons.shape_line_rounded, isFromStaggered ? '' : '.png,.jpg,.jpeg,.mp4,.avi,.mov,.wmv'),
          
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
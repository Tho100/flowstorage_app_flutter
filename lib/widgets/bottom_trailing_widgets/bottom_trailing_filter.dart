import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/sheet_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BottomTrailingFilter {

  final tempData = GetIt.instance<TempDataProvider>();

  Widget _buildFilterTypeButtons(
    String filterName, 
    IconData icon, 
    String filterType,
    Function filterTypePublicStorage,
    Function filterTypeNormal,
    BuildContext context 
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        tempData.origin == OriginFile.public 
          ? filterTypePublicStorage(filterType) 
          : filterTypeNormal(filterType);
          
        Navigator.pop(context);
      },
      icon: Icon(icon),
      label: Text(filterName),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        fixedSize: const Size(112,42),
        backgroundColor: ThemeColor.darkGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35.0),
          side: const BorderSide(color: ThemeColor.whiteGrey),
        ),
      ),
    );
  }

  Future buildFilterTypeAll({
    required Function filterTypePublicStorage,
    required Function filterTypeNormal,
    required BuildContext context
  }) {
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

              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 60,
                  height: 8,
                  decoration: BoxDecoration(
                    color: ThemeColor.thirdWhite,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

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
              
                        _buildFilterTypeButtons("Images",Icons.photo,'.png,.jpg,.jpeg', filterTypePublicStorage, filterTypeNormal, context),
              
                        const SizedBox(height: 3),

                        Row(
      
                          children: [

                          _buildFilterTypeButtons("Text",Icons.text_snippet_rounded,'.txt,.html', filterTypePublicStorage, filterTypeNormal, context),
              
                          const SizedBox(width: 8),
              
                          _buildFilterTypeButtons("Audio",Icons.music_note_rounded,'.mp3,.wav', filterTypePublicStorage, filterTypeNormal, context),
              
                          const SizedBox(width: 8),
              
                          _buildFilterTypeButtons("Videos",Icons.video_collection_rounded,'.mp4,.avi,.mov,.wmv', filterTypePublicStorage, filterTypeNormal, context),
              
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

                            _buildFilterTypeButtons("PDFs",Icons.picture_as_pdf,'.pdf', filterTypePublicStorage, filterTypeNormal, context),
                            const SizedBox(width: 8),
                            _buildFilterTypeButtons("Sheets",Icons.table_chart,'.xls,.xlsx', filterTypePublicStorage, filterTypeNormal, context),

                          ]
                        ),
              
                        const SizedBox(height: 3),

                        Row(
              
                          children: [
              
                            _buildFilterTypeButtons("DOCs",Icons.text_snippet_outlined,'.docx,.doc', filterTypePublicStorage, filterTypeNormal, context),
              
                            const SizedBox(width: 8),
              
                            _buildFilterTypeButtons("CSV",Icons.insert_chart_outlined,'.csv', filterTypePublicStorage, filterTypeNormal, context),
                  
                            const SizedBox(width: 8),

                            _buildFilterTypeButtons("All",Icons.shape_line_rounded,' ', filterTypePublicStorage, filterTypeNormal, context),
                                    
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

  Future buildFilterTypePhotos({
    required Function filterTypePublicStorage,
    required Function filterTypeNormal,
    required BuildContext context
  }) {
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

              const SheetBar(),

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
                    
                    _buildFilterTypeButtons("Images",Icons.photo,'.png,.jpg,.jpeg', filterTypePublicStorage, filterTypeNormal, context),
                    const SizedBox(width: 8),
                    _buildFilterTypeButtons("Videos",Icons.video_collection_rounded,'.mp4,.avi,.mov,.wmv', filterTypePublicStorage, filterTypeNormal, context),
                    const SizedBox(width: 8),
                    _buildFilterTypeButtons("All",Icons.shape_line_rounded,'.png,.jpg,.jpeg,.mp4,.avi,.mov,.wmv', filterTypePublicStorage, filterTypeNormal, context),
          
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
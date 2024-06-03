import 'dart:convert';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/main.dart';
import 'package:flowstorage_fsc/previewer/preview_file.dart';
import 'package:flowstorage_fsc/provider/ps_storage_data.provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/widgets/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultSearchPagePs extends StatelessWidget {

  final String selectedCategory;
  final List<String?> searchDateList;

  ResultSearchPagePs({
    required this.selectedCategory,
    required this.searchDateList,
    Key? key
  }) : super(key: key);

  final tempData = GetIt.instance<TempDataProvider>();
  final psStorageData = GetIt.instance<PsStorageDataProvider>();

  Widget buildResultWidget(double width, double height) {

    final verifySearching = psStorageData.psSearchTitleList.isNotEmpty;

    if (verifySearching) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          const SizedBox(height: 10),
          buildTopHeader(),

          const SizedBox(height: 15),
          buildListView(width, height),

        ],
      );
    } 

    return buildOnEmpty();
    
  }

  Widget buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          Text("Showing results",
            style: GoogleFonts.inter(
              color: ThemeColor.thirdWhite,
              fontWeight: FontWeight.w800,
              fontSize: 14
            )
          ),
          
          const SizedBox(height: 6),
    
          Text(selectedCategory,
            style: GoogleFonts.inter(
              color: ThemeColor.secondaryWhite,
              fontWeight: FontWeight.w800,
              fontSize: 17
            )
          ),
    
        ],
      ),
    );
  }

  Widget buildOnEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            "No results found",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              color: ThemeColor.secondaryWhite,
              fontSize: 21,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            "Check the spelling or try different keywords",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              color: ThemeColor.thirdWhite,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),

        ],
      ),
    );
  }

  Widget buildListView(double width, double height) {

    const itemExtentValue = 90.0;
    const bottomExtraSpacesHeight = 95.0;

    return SizedBox(
      width: width,
      height: height,
      child: RawScrollbar(
        radius: const Radius.circular(38),
        thumbColor: ThemeColor.darkWhite,
        minThumbLength: 2,
        thickness: 2,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: bottomExtraSpacesHeight),
          itemExtent: itemExtentValue,
          itemCount: psStorageData.psSearchTitleList.length,
          itemBuilder: (context, index) {

            final imageBytes = base64.decode(psStorageData.psSearchImageBytesList[index]);
            
            final title = psStorageData.psSearchTitleList[index];
            final uploaderName = psStorageData.psSearchUploaderList[index];
            final uploadDate = searchDateList[index];

            return InkWell(
              onTap: () => openSearchedFile(index),
              child: Ink(
                color: ThemeColor.darkBlack,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.memory(imageBytes,
                      fit: BoxFit.cover, height: 70, width: 62
                    ),
                  ),
                  title: Transform.translate(
                    offset: const Offset(0, -6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            color: ThemeColor.justWhite,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),              

                        const SizedBox(height: 3),      

                        Text(
                          "Uploaded by $uploaderName",
                          style: GoogleFonts.inter(
                            color: ThemeColor.secondaryWhite,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        Text(uploadDate!,
                          style: GoogleFonts.inter(
                            color: ThemeColor.thirdWhite, 
                            fontWeight: FontWeight.w800,
                            fontSize: 12.8
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void openSearchedFile(int index) {

    final fileName = psStorageData.psSearchNameList[index];

    tempData.setCurrentFileName(fileName);
    tempData.setOrigin(OriginFile.publicSearching);

    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (_) => PreviewFile(
          selectedFilename: fileName,
          tappedIndex: index
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height-150;

    return Scaffold(
      appBar: CustomAppBar(
        title: "", 
        context: context,
      ).buildAppBar(),
      body: buildResultWidget(width, height),
    );
  }

}
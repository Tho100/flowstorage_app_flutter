import 'dart:typed_data';

import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => AcitivtyPageState();
}

class AcitivtyPageState extends State<ActivityPage> {

  final storageData = GetIt.instance<StorageDataProvider>();

  List<String> recentFilesName = [];
  List<String> recentDate = [];
  List<Uint8List?> recentImageBytes = [];

  List<String> mostUploadedFilesName = [];
  List<String> mostUploadedDate = [];
  List<Uint8List?> mostUploadedImageBytes = [];

  String mostUploadTag = "";

  Widget buildBody(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          
          buildPublicStorageBanner(width),
    
          const SizedBox(height: 8),
    
          const Divider(color: ThemeColor.lightGrey),
    
          const SizedBox(height: 8),
    
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 8.0, left: 18.0),
              child: Row(
                children: [
                  Icon(Icons.schedule_outlined, color: ThemeColor.justWhite, size: 25),
                  SizedBox(width: 8),
                  Text("Recent", 
                    style: TextStyle(
                      color: ThemeColor.justWhite,
                      fontWeight: FontWeight.w500,
                      fontSize: 18
                    ),
                  ),
                ],
              ),
            ),
          ),
    
          const SizedBox(height: 16),
    
          SizedBox(
            height: 285,
            width: width-18,
            child: buildRecentListView()
          ),
    
          const SizedBox(height: 18),
    
          if(mostUploadedImageBytes.length >= 2)
          buildMostUploaded(width),
    
          const SizedBox(height: 25),

        ],
      ),
    );
  }
  
  Widget buildMostUploaded(double width) {

    final fileTypeFirst = mostUploadedFilesName[0].split('.').last;
    final fileTypeSecond = mostUploadedFilesName[1].split('.').last;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 165,
                height: 265,
                decoration: BoxDecoration(
                  color: ThemeColor.mediumGrey,
                  borderRadius: BorderRadius.circular(12)
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(mostUploadedImageBytes[0]!,
                    fit: Globals.generalFileTypes.contains(fileTypeFirst) 
                    ? BoxFit.scaleDown : BoxFit.cover,
                  ),
                )
              ),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: SizedBox(
                    width: 145,
                    child: Text(mostUploadedFilesName[0],
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: ThemeColor.secondaryWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 2),

              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(mostUploadedDate[0],
                    style: const TextStyle(
                      color: ThemeColor.thirdWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
    
          const SizedBox(width: 10),
    
          Column(
            children: [
              Container(
                width: width-205,
                height: 95,
                decoration: BoxDecoration(
                  color: ThemeColor.secondaryPurple,
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("You mostly uploaded $mostUploadTag",
                    style: GoogleFonts.poppins(
                      color: ThemeColor.justWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 19
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: width-205,
                    height: 155,
                    decoration: BoxDecoration(
                      color: ThemeColor.mediumGrey,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(mostUploadedImageBytes[1]!,
                        fit: Globals.generalFileTypes.contains(fileTypeSecond) 
                        ? BoxFit.scaleDown : BoxFit.cover,
                      ),
                    )
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(
                        width: 175,
                        child: Text(mostUploadedFilesName[1],
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: ThemeColor.secondaryWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(mostUploadedDate[1],
                        style: const TextStyle(
                          color: ThemeColor.thirdWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    
        ],
      ),
    );
  }

  Widget buildRecentListView() {

    return ListView.builder(
      itemCount: recentFilesName.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {

        final fileType = recentFilesName[index].split('.').last;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          width: 145,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(recentImageBytes[index]!,
                      fit: Globals.generalFileTypes.contains(fileType) ? BoxFit.scaleDown : BoxFit.cover, 
                      height: 225, width: 145
                    ),
                  ),

                  if(Globals.videoType.contains(fileType))
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 12),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: ThemeColor.mediumGrey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.videocam_outlined, color: ThemeColor.justWhite, size: 22)
                    ),
                  ),
                  
                ],
              ),
              
              const SizedBox(height: 12),

              Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  width: 145,
                  child: Text(recentFilesName[index],
                    style: const TextStyle(
                      color: ThemeColor.secondaryWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),

              const SizedBox(height: 2),

              Align(
                alignment: Alignment.bottomLeft,
                child: Text(recentDate[index],
                  style: const TextStyle(
                    color: ThemeColor.thirdWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget buildPublicStorageBanner(double width) {
    return GestureDetector(
      onTap: () {
        //TODO: Bring user to public page
      },
      child: Container(
        width: width-32,
        height: 100,
        decoration: BoxDecoration(
          color: ThemeColor.justWhite,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Row(
          children: [
    
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Transform.scale(
                scale: 1.2,
                child: Image.asset('assets/images/public_icon.jpg')
              ),
            ),
    
            const SizedBox(width: 25),
    
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Discover Public Storage",
                  style: GoogleFonts.poppins(
                    color: ThemeColor.darkWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.left,
                ),
                Text("Open community for cloud storage",  
                  style: GoogleFonts.poppins(
                    color: ThemeColor.thirdWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
    
          ],
        ),
      ),
    );
  }

  List<String> filterNamesByType(String fileType, int count) {
    return storageData.fileNamesFilteredList
      .where((fileName) => fileName.contains(fileType))
      .take(count)
      .toList();
  }

  List<String> filterDatesByType(String fileType, int count) {
    return storageData.fileDateFilteredList
      .asMap()
      .entries
      .where((entry) => storageData.fileNamesFilteredList[entry.key].contains(fileType))
      .take(count)
      .map((entry) {
        final fullDate = entry.value;
        final dotIndex = fullDate.indexOf(' • ');
        if (dotIndex != -1 && dotIndex + 4 < fullDate.length) {
          return fullDate.substring(dotIndex + 4);
        }
        return fullDate;
      })
      .toList();
  }

  List<Uint8List?> filterImagesByType(String fileType, int count) {
    return storageData.imageBytesFilteredList
      .asMap()
      .entries
      .where((entry) => storageData.fileNamesFilteredList[entry.key].contains(fileType))
      .take(count)
      .map((entry) => entry.value)
      .toList();
  }


  String findMode(List<String> strings) {

    Map<String, int> frequencyMap = {};

    for (String str in strings) {
      frequencyMap[str] = (frequencyMap[str] ?? 0) + 1;
    }

    String? mode;
    int maxFrequency = 0;

    frequencyMap.forEach((key, value) {
      if (value > maxFrequency) {
        maxFrequency = value;
        mode = key;
      }
    });

    return mode!;

  }

  void initializeMostUploadData() {

    const Map<String, String> mostUploadMap = {
      'png': "Image",
      'jpg': "Image",
      'jpeg': "Image",

      'txt': "Text",
      'sql': "Text",
      'js': "Text",
      'css': "Text",
      'xml': "Text",
      'py': "Text",
      'md': "Text",
      'csv': "Text",
      'html': "Text",

      'pdf': "Document",
      'doc': "Document",
      'docx': "Document",
      'pptx': "Document",
      'ptx': "Document",
      'xlsx': "Document",
      'xls': "Document",
      
      'exe': "GlobalsTable.psExe",
      'msi': "GlobalsTable.psMsi",
      'apk': "GlobalsTable.psApk",

      'mp4': "Video",
      'avi': "Video",
      'mov': "Video",
      'wmv': "Video",

      'mp3' : "Audio",
      'wav': "Audio"
    };

    final fileNames = storageData.fileNamesFilteredList.toList();
    final fileTypes = fileNames.map((fileName) => fileName.split('.').last).toList();
    final modeFileType = findMode(fileTypes);

    mostUploadTag = mostUploadMap[modeFileType]!;
    
    mostUploadedImageBytes = filterImagesByType(modeFileType, 2);
    mostUploadedFilesName = filterNamesByType(modeFileType, 2);
    mostUploadedDate = filterDatesByType(modeFileType, 2);

  }

  void initializeRecentData() {

    recentFilesName = filterNamesByType('.', 5);
    recentDate = filterDatesByType('.', 5);
    recentImageBytes = filterImagesByType('.', 5);

  }

  @override
  void initState() {
    super.initState();
    initializeRecentData();
    initializeMostUploadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ThemeColor.darkBlack,
        title: const Text("Activity",
          style: GlobalsStyle.appBarTextStyle
        ),
      ),
      body: buildBody(context),
    );
  }

}
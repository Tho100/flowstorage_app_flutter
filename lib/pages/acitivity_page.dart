import 'dart:typed_data';

import 'package:flowstorage_fsc/constant.dart';
import 'package:flowstorage_fsc/global/globals.dart';
import 'package:flowstorage_fsc/helper/date_parser.dart';
import 'package:flowstorage_fsc/helper/navigate_page.dart';
import 'package:flowstorage_fsc/helper/random_generator.dart';
import 'package:flowstorage_fsc/interact_dialog/activity_image_previewer.dart';
import 'package:flowstorage_fsc/provider/storage_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_data_provider.dart';
import 'package:flowstorage_fsc/provider/temp_storage.dart';
import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flowstorage_fsc/themes/theme_style.dart';
import 'package:flowstorage_fsc/widgets/video_placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatefulWidget {

  final VoidCallback publicStorageFunction;

  const ActivityPage({
    required this.publicStorageFunction,
    Key? key
  }) : super(key: key);

  @override
  State<ActivityPage> createState() => AcitivtyPageState();
}

class AcitivtyPageState extends State<ActivityPage> {

  final storageData = GetIt.instance<StorageDataProvider>();
  final tempStorageData = GetIt.instance<TempStorageProvider>();
  final tempData = GetIt.instance<TempDataProvider>();

  List<String> recentFilesName = [];
  List<String> recentDate = [];
  List<Uint8List?> recentImageBytes = [];

  List<String> mostUploadedFilesName = [];
  List<String> mostUploadedDate = [];
  List<Uint8List?> mostUploadedImageBytes = [];

  List<String> legacyFilesName = [];
  List<String> legacyDate = [];
  List<Uint8List?> legacyImageBytes = [];

  List<String> directoriesList = [];
  List<String> foldersList = [];

  Uint8List photoOfTheDayImageBytes = Uint8List(0);
  String photoOfTheDayFileName = "";

  String mostUploadTag = "";

  Widget buildBody(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    final isCanShowData = tempData.origin != OriginFile.public && tempData.origin != OriginFile.sharedOther && tempData.origin != OriginFile.sharedMe;

    return SingleChildScrollView(
      child: Column(
        children: [
          
          buildPublicStorageBanner(width),
    
          const SizedBox(height: 8),
    
          const Divider(color: ThemeColor.lightGrey),
    
          const SizedBox(height: 4),

          if(recentFilesName.isEmpty || tempData.origin == OriginFile.public || tempData.origin == OriginFile.sharedOther || tempData.origin == OriginFile.sharedMe)
          buildOnEmpty(context),

          if(recentFilesName.isNotEmpty && isCanShowData) ... [
          buildHeader("Recent", Icons.schedule_outlined),
    
          const SizedBox(height: 16),
    
          SizedBox(
            height: 285,
            width: width-18,
            child: buildRecentListView()
          ),
        
          const SizedBox(height: 18),
    
          if(mostUploadedImageBytes.length >= 2 && isCanShowData)
          buildMostUploaded(width),

          const SizedBox(height: 18),

          if(directoriesList.isNotEmpty || foldersList.isNotEmpty) ... [
            buildHeader("Directory / Folder", Icons.folder_outlined),
            const SizedBox(height: 18),
          ],

          if(directoriesList.isNotEmpty)
          SizedBox(
            height: 70,
            width: width-18,
            child: buildDirectories("directory")
          ),

          if(foldersList.isNotEmpty)
          SizedBox(
            height: 70,
            width: width-18,
            child: buildDirectories("folder")
          ),

          if(photoOfTheDayFileName.isNotEmpty) ... [
          const SizedBox(height: 18),

          buildHeader("Photo you may like", Icons.star_outline),

          const SizedBox(height: 18),

          buildPhotoOfTheDay(width),

          ],

          if(legacyFilesName.isNotEmpty) ... [
          const SizedBox(height: 28),

          Row(
            children: [
              buildHeader("Legacy", Icons.hourglass_bottom_outlined),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text("Files older than 30 days",
                  style: TextStyle(
                    color: ThemeColor.thirdWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 90,
            width: width-18,
            child: buildLegacy()
          ),

          ],

          const SizedBox(height: 12),

          const Padding(
            padding: EdgeInsets.only(left: 22, right: 22),
            child: Divider(color: ThemeColor.lightGrey)
          ),

          const SizedBox(height: 15),

          buildLastBottomContainers(width),

          const SizedBox(height: 10),

          buildGetSupremeContainer(width),

          ],

          const SizedBox(height: 40),

        ],
      ),
    );
  }

  Widget buildHeader(String headerMessage, IconData icon) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 18.0),
        child: Row(
          children: [
            Icon(icon, color: ThemeColor.justWhite, size: 25),
            const SizedBox(width: 8),
            Text(headerMessage, 
              style: const TextStyle(
                color: ThemeColor.justWhite,
                fontWeight: FontWeight.w500,
                fontSize: 18
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOnEmpty(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height-285,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rocket_outlined, size: 115, color: ThemeColor.secondaryWhite),
            SizedBox(height: 12),
            Text("No activity to see here",
              style: TextStyle(
                color: ThemeColor.secondaryWhite,
                fontWeight: FontWeight.w600,
                fontSize: 16
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget buildMostUploadedWidgets(int index, double width, double height) {

    final fileType = mostUploadedFilesName[index].split('.').last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            final fileName = mostUploadedFilesName[index];
            final imageBytes = mostUploadedImageBytes[index];
            ActivityImagePreviewer.showPreviewer(fileName, imageBytes);
          },
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: ThemeColor.mediumGrey,
              borderRadius: BorderRadius.circular(12)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                mostUploadedImageBytes[index]!,
                fit: Globals.generalFileTypes.contains(fileType) 
                ? BoxFit.scaleDown : BoxFit.cover,
              ),
            )
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              width: 145,
              child: Text(mostUploadedFilesName[index],
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
            child: Text(mostUploadedDate[index],
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
    );

  }
  
  Widget buildGetSupremeContainer(double width) {

    final linearGradient = const LinearGradient(
      colors: <Color>[ThemeColor.secondaryPurple, ThemeColor.darkPurple, ThemeColor.justWhite],
    ).createShader(const Rect.fromLTWH(55.0, 0.0, 200.0, 70.0));

    const linearGradientBorder = LinearGradient(
      colors: <Color>[ThemeColor.secondaryPurple, ThemeColor.darkPurple, ThemeColor.justWhite],
    );

    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              NavigatePage.goToPageUpgrade();
            },
            child: Stack(
              children: [
                Container(
                  width: width-35,
                  height: 125,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: linearGradientBorder, // Use your linear gradient here
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    width: width- 35 - 4,
                    height: 125 - 4,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("Get more storage & features with",
                                style: GoogleFonts.poppins(
                                  color: ThemeColor.justWhite,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: ThemeColor.justWhite)
                            ],
                          ),
                          Text("Supreme",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              foreground: Paint()..shader = linearGradient,
                              fontSize: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLastBottomContainers(double width) {

    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          Expanded(
            child: Container(
              height: 95,
              decoration: BoxDecoration(
                color: ThemeColor.secondaryPurple,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("Last upload on \n${recentDate[0]}",
                  style: GoogleFonts.poppins(
                    color: ThemeColor.justWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 19
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                NavigatePage.goToPageStatistics();
              },
              child: Container(
                width: width-280,
                height: 95,
                decoration: BoxDecoration(
                  color: ThemeColor.justWhite,
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Go to \nstatistics",
                        style: GoogleFonts.poppins(
                          color: ThemeColor.secondaryPurple,
                          fontWeight: FontWeight.w600,
                          fontSize: 19
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: ThemeColor.secondaryPurple)
                    ],
                  ),
                ),
              ),
            ),
          ),
    
        ],
      ),
    );

  } 

  Widget buildMostUploaded(double width) {

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    
          buildMostUploadedWidgets(0, 165, 265),
    
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

              buildMostUploadedWidgets(1, width-205, 155),

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

        return GestureDetector(
          onTap: () {
            final fileName = recentFilesName[index];
            final imageBytes = recentImageBytes[index];
            ActivityImagePreviewer.showPreviewer(fileName, imageBytes);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            width: 145,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
        
                    Container(
                      width: 145,
                      height: 225,
                      decoration: BoxDecoration(
                        color: ThemeColor.mediumGrey,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(recentImageBytes[index]!,
                          fit: Globals.generalFileTypes.contains(fileType) ? BoxFit.scaleDown : BoxFit.cover, 
                          height: 225, width: 145
                        ),
                      ),
                    ),
        
                    if(Globals.videoType.contains(fileType))
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: SizedBox(
                        height: 225,
                        child: Center(
                          child: VideoPlaceholderWidget()
                        ),
                      )
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
          ),
        );
      },
    );
  }

  Widget buildDirectoryWidget(String name, String type) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: ThemeColor.darkGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(
        minWidth: 165,
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 18.0),
        child: Row(
          children: [
            Image.asset(
              'assets/images/dir1.jpg',
              width: 70,
              height: 70,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                  style: const TextStyle(
                    color: ThemeColor.secondaryWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(type,
                  style: const TextStyle(
                    color: ThemeColor.thirdWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.left
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDirectories(String type) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ListView.builder(
        itemCount: type == "directory" 
          ? directoriesList.length : foldersList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
    
                type == "directory" 
                ? buildDirectoryWidget(directoriesList[index], "Directory") 
                : buildDirectoryWidget(foldersList[index], "Folder"),
                
                const SizedBox(width: 12),
                
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildPhotoOfTheDay(double width) {
    return GestureDetector(
      onTap: () {
        ActivityImagePreviewer.showPreviewer(photoOfTheDayFileName, photoOfTheDayImageBytes);
      },
      child: SizedBox(
        width: width-45,
        height: 315,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(photoOfTheDayImageBytes,
            fit: BoxFit.cover, width: width-40, height: 315,
          ),
        ),
      ),
    );
  }

  Widget buildLegacyWidget(Uint8List imageBytes, String fileName, String date) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: ThemeColor.darkGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(
        minWidth: 205,
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 18.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  imageBytes,
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName,
                  style: const TextStyle(
                    color: ThemeColor.secondaryWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(date,
                  style: const TextStyle(
                    color: ThemeColor.thirdWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.left
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLegacy() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ListView.builder(
        itemCount: legacyFilesName.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
    
                buildLegacyWidget(legacyImageBytes[index]!, legacyFilesName[index], legacyDate[index]),
                
                const SizedBox(width: 12),
                
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildPublicStorageBanner(double width) {
    return GestureDetector(
      onTap: () {
        widget.publicStorageFunction();
        Navigator.pop(context);
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
              padding: const EdgeInsets.only(left: 18.0),
              child: Transform.scale(
                scale: 1.0,
                child: Image.asset('assets/images/public_icon.jpg')
              ),
            ),
    
            const SizedBox(width: 20),
    
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
                Text("Open community for file sharing",  
                  style: GoogleFonts.poppins(
                    color: ThemeColor.thirdWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),

            const Spacer(),

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

    if(storageData.fileNamesFilteredList.isNotEmpty) {

      final fileNames = storageData.fileNamesFilteredList.toList();
      final fileTypes = fileNames.map((fileName) => fileName.split('.').last).toList();
      final modeFileType = findMode(fileTypes);

      mostUploadTag = mostUploadMap[modeFileType]!;
      
      mostUploadedImageBytes = filterImagesByType(modeFileType, 2);
      mostUploadedFilesName = filterNamesByType(modeFileType, 2);
      mostUploadedDate = filterDatesByType(modeFileType, 2);

    }

  }

  void initializeRecentData() {

    final isCanShowData = tempData.origin != OriginFile.public && tempData.origin != OriginFile.sharedOther && tempData.origin != OriginFile.sharedMe;

    if(!isCanShowData) {
      return;
    }

    if(tempData.origin == OriginFile.offline) {
      recentFilesName = filterNamesByType('.', 5);
      recentDate = filterDatesByType('.', 5);
      recentImageBytes = filterImagesByType('.', 5);
      return;
    }

    final removedDirectoryDateList = storageData.fileDateFilteredList.where((type) => type.contains(GlobalsStyle.dotSeperator)).toList();

    final filteredFileName = filterNamesByType('.', removedDirectoryDateList.length);

    List<Map<String, dynamic>> itemList = [];

    for (int i = 0; i < filteredFileName.length; i++) {
      itemList.add({
        'file_name': storageData.fileNamesFilteredList[i],
        'image_byte': storageData.imageBytesFilteredList[i],
        'upload_date': DateParser(date: storageData.fileDateFilteredList[i]).parse(),
      });
    }

    itemList = itemList.where((item) => item['file_name'].contains('.')).toList();

    itemList.sort((a, b) => b['upload_date'].compareTo(a['upload_date']));

    for (final item in itemList) {
      recentFilesName.add(item['file_name']);
      recentImageBytes.add(item['image_byte']);
      recentDate.add(formatDateTime(item['upload_date']));
    }

    itemList.clear();

  }

  String formatDateTime(DateTime dateTime) {

    final now = DateTime.now();

    final difference = now.difference(dateTime).inDays;
    final adjustedDateTime = difference.isNegative ? dateTime.add(const Duration(days: 1)) : dateTime;

    return DateFormat('MMM dd yyyy').format(adjustedDateTime);

  }

  void initializeDirectoriesData() {

    final getDirectory = tempStorageData.directoryNameList;
    final getFolder = tempStorageData.folderNameList;

    directoriesList.addAll(getDirectory);
    foldersList.addAll(getFolder);

  }

  void initializePhotoOfTheDayData() {

    final filesName = storageData.fileNamesFilteredList
      .where((fileName) => Globals.imageType.any((type) => fileName.toLowerCase().endsWith(type)))
      .toList();
    
    if(filesName.isNotEmpty) {
      final generateRandomNumber = Generator.generateRandomInt(0, filesName.length - 1);
      photoOfTheDayFileName = filesName[generateRandomNumber];

      photoOfTheDayImageBytes = filterImagesByType(photoOfTheDayFileName, 1)[0]!;

    }

  }

  void initializeLegacyData() {

    final currentDate = DateTime.now();

    final olderThan30DaysFiles = storageData.fileDateFilteredList
      .asMap()
      .entries
      .where((entry) => storageData.fileNamesFilteredList[entry.key].contains('.'))
      .where((entry) {
        final fullDate = entry.value;
        final match = RegExp(r'(\d+) days ago\s+•\s+(\w+ \d+ \d+)').firstMatch(fullDate);

        if (match != null) {
          final dateString = match.group(2)!;

          final dateTimeFormat = DateFormat('MMM dd yyyy');
          final fileDate = dateTimeFormat.parse(dateString);

          final differenceInDays = currentDate.difference(fileDate).inDays;

          return differenceInDays > 30;
        }

        return false;
      })
      .toList();

    final filesNames = olderThan30DaysFiles
      .map((entry) => storageData.fileNamesFilteredList[entry.key])
      .toList();

    final imagesBytes = olderThan30DaysFiles
      .map((entry) => storageData.imageBytesFilteredList[entry.key])
      .toList();

    final filesDate = olderThan30DaysFiles
      .map((entry) => storageData.fileDateFilteredList[entry.key])
      .toList();

    legacyFilesName.addAll(filesNames);
    legacyDate.addAll(filesDate);
    legacyImageBytes.addAll(imagesBytes);

  }

  @override
  void initState() {
    super.initState();
    initializeRecentData();
    initializeMostUploadData();
    initializeDirectoriesData();
    initializePhotoOfTheDayData();
    initializeLegacyData();
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